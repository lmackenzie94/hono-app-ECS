import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  GetCommand,
  UpdateCommand
} from '@aws-sdk/lib-dynamodb';

const app = new Hono();

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
  // NOTE: In production, you typically don't want to specify credentials explicitly or set a custom endpoint
  // AWS will handle authentication through IAM roles
  ...(process.env.IS_LOCAL && {
    endpoint: process.env.DYNAMODB_ENDPOINT,
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    }
  })
});

const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;

app.get('/health', c => c.json({ status: 'ok' }));

app.onError((err, c) => {
  console.error(`${err}`);
  return c.json({ error: 'Internal Server Error' }, 500);
});

app.get('/', async c => {
  const getCommand = new GetCommand({
    TableName: TABLE_NAME,
    Key: {
      id: 'counter'
    }
  });

  try {
    const data = await docClient.send(getCommand);
    const count = data.Item?.count || 0;

    return c.html(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>View Counter</title>
          <style>
          body {
            font-family: sans-serif;
            margin-top: 2rem;
            background-color: #f5f5f5;
            text-align: center;
            line-height: 1.3;
          }
          main {
            width: min(100%, 800px);
            margin: 0 auto;
          }
          h1 {
            font-weight: bold;
            padding-bottom: 2rem;
            border-bottom: 1px solid #ccc;
          }
          #count {
            background-color: #ffffff;
            padding: 0.5rem 1rem;
            border-radius: 0.25rem;
          }
          p {
            font-size: 1.1rem;
            line-height: 1.5;
          }
          button {
            display: block;
            font-size: 1.5rem;
            padding: 0.5rem 1rem;
            background-color:rgb(0, 96, 198);
            color: #fff;
            border: none;
            border-radius: 0.25rem;
            cursor: pointer;
            transition: background-color 0.3s ease;
            margin: 0rem auto;
          }
          button:hover {
            background-color: rgb(0, 86, 178);
          }
          form {
            margin-top: 2rem;
          }
        </style>
        </head>
        <body>
          <header>
            <h1>Current Views: <span id="count">${count}</span></h1>
          </header>
          <main>
           <p>
            This is a simple <strong>Hono</strong> Node.js application that implements a view counter using <strong>AWS DynamoDB</strong> and is deployed on <strong>AWS ECS Fargate</strong>. The infrastructure is managed using <strong>Terraform</strong>, which (among other things) provisions an <strong>Application Load Balancer</strong> to distribute traffic across multiple container instances. The application's <strong>Docker image</strong> is stored in <strong>Amazon Elastic Container Registry (ECR)</strong>.
           </p>
            <form action="/increment" method="post">
              <button type="submit">Add a view 👀</button>
            </form>
          </main>
        </body>
      </html>
    `);
  } catch (error) {
    console.error('Error fetching count:', error);
    return c.text('Error fetching count', 500);
  }
});

app.post('/increment', async c => {
  const updateCommand = new UpdateCommand({
    TableName: TABLE_NAME,
    Key: {
      id: 'counter'
    },
    UpdateExpression: 'SET #count = if_not_exists(#count, :zero) + :inc',
    ExpressionAttributeNames: {
      '#count': 'count'
    },
    ExpressionAttributeValues: {
      ':inc': 1,
      ':zero': 0
    },
    ReturnValues: 'UPDATED_NEW'
  });

  try {
    await docClient.send(updateCommand);
    return c.redirect('/');
  } catch (error) {
    console.error('Error incrementing count:', error);
    return c.text('Error incrementing count', 500);
  }
});

serve({
  fetch: app.fetch,
  port: 3000
});
