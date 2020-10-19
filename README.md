# HTTP Cloud Function Boilerplate

Boilerplate code to spin-up a new http-triggered Google Cloud Function. It includes...

- a comprehensive directory scaffold

- airbnb customized linting config

- express routing and validation based on @brdu/express-swagger

- scripts for local (dev) deployments and for ci/cd production (live) deployments based on Github Actions

# Express and @brdu/express-swagger

The **@brdu/express-swagger** package consumes a swagger (OAS2) YAML to build your API routes and request validations.

You don't need to worry about making changes to the `src/index.js` file, unless you change the default directories that hold your API specifications and your controllers.

The package initialization has two required properties, `swaggerPath` and `controllersPath`, and an optional property, `fileNameCasing`.

`swaggerPath` is the path your API specification swagger (OAS2) YAML.

`controllersPath` is the path your controllers directory, where the controller for each API operation can be found.

`fileNameCasing` is used to indicate which type of casing you use when naming your directories and files. It accepts: KEBAB, CAMEL and SNAKE. If not declared, it defaults to KEBAB.

This is the package initialization as found in the file `src/index.js`:

```javascript
const serviceSettings = {
  swaggerPath: path.resolve(__dirname, './specifications/oas-file.yaml'),
  controllersPath: path.resolve(__dirname, './controllers'),
}

const { routes, validator } = require('@brdu/express-swagger')(serviceSettings)
```

The deconstructed property `routes` is an object that store all details required to build the routes in Express application. `validtor` is a middleware that verifies every aspect of a request, from required headers and parameters to request bodies. This middleware also handles error responses whenever a request doesn't pass its validation.

For more information, review the package README at [https://github.com/buffolander/brdu-express-swagger](https://github.com/buffolander/brdu-express-swagger).

# Environment variables

The `.env` file stores both **deployment** and **runtime** variables. Deployment variables cover details about your function and your GCP project required by the deployment scripts. Runtime variables are those that are actually part of your code.

Whenever you execute your function locally `dotenv` will load both variable type into the running process. This won't apply when you deploy a function in DEV or LIVE (production) stages.

## Setting up your deployment variables

```bash
# Function details
STAGE=dev
FUNCTION_NAME=?
RUNTIME=nodejs12
MEMORY=256MB
TIMEOUT=30s
VPC_CONNECTOR=?
# Project details
PROJECT=?
PROJECT_NO=?
SERVICE_ACCT_EMAIL=?
SERVICE_ACCT_KEYFILE_PATH=?
```

These are the deployment variables you need to setup. They may be broken down in two parts: Function and Project details.

If you're working on a team, chances are when deploying a function from your local machine you'll be using a personal service account keyfile, sent to you by DevOps. Your service account should have limited privileges, like being limited to deployment tasks.

`SERVICE_ACCT_KEYFILE_PATH` is were you specify the full path in your local machine were you service account keyfile is stored; like `/users/buffolander/.gcloud/my-keyfile.json`.

`SERVICE_ACCT_EMAIL` can be found in your keyfile. You must also update its values in the `.env` file.

## Runtime variables in DEV vs LIVE

When deploying a function from your local machine, it should ALWAYS point to `STAGE=dev`. The deployment script then deploys the function as `dev-FUNCTION_NAME`.

Attempting to deploy a function into production from your local machine may result in error, unless your service account carries a wide range of privileges.

It's an expected behavior as deployment scripts handle runtime variables differently in each stage. Deployments into production are expected to run exclusively from the Github Action, triggered by a push to the master (or main) branch.

When deployed locally the script will authenticate with gcloud CLI using your personal service account and it will add the runtime variables found in the `.env` file to the deployment payload.

When deployed into production via Github Actions the script will authenticate with gcloud CLI using the `SERVICE_ACCOUNT_KEY` secret setup either in your repository or organization secrets. The script will then grab the runtime variables keys found in the `.env` file and fetch their values from **Cloud Secrets Manager**, thus adding them to the deployment payload.
