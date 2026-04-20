import type { IncomingMessage, ServerResponse } from "node:http";

type App = (req: IncomingMessage, res: ServerResponse) => void;

let cachedApp: App | null = null;
let initPromise: Promise<App> | null = null;

async function bootstrap(): Promise<App> {
  const { createDb, applyPendingMigrations, inspectMigrations } = await import(
    "@paperclipai/db"
  );
  const { createApp } = await import("../server/src/app.js");
  const {
    createBetterAuthHandler,
    createBetterAuthInstance,
    resolveBetterAuthSession,
  } = await import("../server/src/auth/better-auth.js");
  const { createStorageService } = await import(
    "../server/src/storage/service.js"
  );
  const { createLocalDiskStorageProvider } = await import(
    "../server/src/storage/local-disk-provider.js"
  );
  const { createS3StorageProvider } = await import(
    "../server/src/storage/s3-provider.js"
  );

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error("DATABASE_URL environment variable is required");
  }

  const migrationState = await inspectMigrations(databaseUrl);
  if (migrationState.status === "needsMigrations") {
    await applyPendingMigrations(databaseUrl);
  }

  const db = createDb(databaseUrl);

  const publicUrl = process.env.PAPERCLIP_PUBLIC_URL ?? process.env.VERCEL_PROJECT_PRODUCTION_URL
    ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
    : undefined;

  const trustedOrigins: string[] = [];
  if (publicUrl) trustedOrigins.push(new URL(publicUrl).origin);
  if (process.env.VERCEL_URL) trustedOrigins.push(`https://${process.env.VERCEL_URL}`);
  if (process.env.VERCEL_BRANCH_URL) trustedOrigins.push(`https://${process.env.VERCEL_BRANCH_URL}`);
  if (process.env.BETTER_AUTH_TRUSTED_ORIGINS) {
    trustedOrigins.push(
      ...process.env.BETTER_AUTH_TRUSTED_ORIGINS.split(",").map((s) => s.trim()).filter(Boolean),
    );
  }

  const minimalConfig = {
    authBaseUrlMode: "explicit" as const,
    authPublicBaseUrl: publicUrl,
    authDisableSignUp: process.env.PAPERCLIP_AUTH_DISABLE_SIGN_UP === "true",
    deploymentMode: "authenticated" as const,
    deploymentExposure: "public" as const,
    allowedHostnames: [] as string[],
  };

  const auth = createBetterAuthInstance(db, minimalConfig as any, trustedOrigins);
  const betterAuthHandler = createBetterAuthHandler(auth);
  const resolveSession = (req: any) => resolveBetterAuthSession(auth, req);

  let storageService;
  if (process.env.PAPERCLIP_STORAGE_PROVIDER === "s3") {
    storageService = createStorageService(
      createS3StorageProvider({
        bucket: process.env.PAPERCLIP_STORAGE_S3_BUCKET ?? "",
        region: process.env.PAPERCLIP_STORAGE_S3_REGION ?? "us-east-1",
        endpoint: process.env.PAPERCLIP_STORAGE_S3_ENDPOINT,
        prefix: process.env.PAPERCLIP_STORAGE_S3_PREFIX ?? "",
        forcePathStyle: process.env.PAPERCLIP_STORAGE_S3_FORCE_PATH_STYLE === "true",
      }),
    );
  } else {
    storageService = createStorageService(createLocalDiskStorageProvider("/tmp/paperclip-storage"));
  }

  const app = await createApp(db as any, {
    uiMode: "none",
    serverPort: 0,
    storageService,
    deploymentMode: "authenticated",
    deploymentExposure: "public",
    allowedHostnames: [],
    bindHost: "0.0.0.0",
    authReady: true,
    companyDeletionEnabled: process.env.PAPERCLIP_ENABLE_COMPANY_DELETION === "true",
    betterAuthHandler,
    resolveSession,
  });

  return app as unknown as App;
}

function getApp(): Promise<App> {
  if (cachedApp) return Promise.resolve(cachedApp);
  if (!initPromise) {
    initPromise = bootstrap().then((app) => {
      cachedApp = app;
      return app;
    });
  }
  return initPromise;
}

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  if (!process.env.DATABASE_URL) {
    res.statusCode = 503;
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ error: "DATABASE_URL not configured" }));
    return;
  }
  const app = await getApp();
  app(req, res);
}
