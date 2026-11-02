const endpoint = process.env.AWS_LAMBDA_HTTP_ENDPOINT;
if (!endpoint) throw new Error("AWS_LAMBDA_HTTP_ENDPOINT is required");
const separator = endpoint.lastIndexOf(":");
process.env.HOSTNAME = endpoint.slice(0, separator);
process.env.PORT = endpoint.slice(separator + 1);
process.env.NODE_ENV = "production";
// eslint-disable-next-line @typescript-eslint/no-require-imports
require("./server.js");
