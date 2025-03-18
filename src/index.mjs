import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  GetCommand,
  UpdateCommand
} from '@aws-sdk/lib-dynamodb';
import { serveStatic } from '@hono/node-server/serve-static';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = new Hono();

app.use('/styles.css', serveStatic({ path: 'styles.css' }));

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

    const htmlPath = path.join(__dirname, 'index.html');
    let htmlTemplate = fs.readFileSync(htmlPath, 'utf8');

    htmlTemplate = htmlTemplate.replace('{{count}}', count);

    return c.html(htmlTemplate);
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
