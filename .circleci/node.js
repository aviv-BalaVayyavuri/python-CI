const AWS = require('aws-sdk');
const zlib = require('zlib');

exports.handler = async (event) => {
  const s3 = new AWS.S3();
  const cloudwatchlogs = new AWS.CloudWatchLogs();
  
  const bucket = event.Records[0].s3.bucket.name;
  const key = event.Records[0].s3.object.key;

  // Download and decompress the log file from S3
  const logData = await s3.getObject({ Bucket: bucket, Key: key }).promise();
  const logBody = zlib.gunzipSync(logData.Body).toString('utf-8');

  // Prepare the log events for CloudWatch
  const logEvents = logBody.split('\n').filter(Boolean).map((line) => ({
    message: line,
    timestamp: new Date().getTime(),
  }));

  // Send the log events to CloudWatch
  const logGroupName = process.env.LOG_GROUP_NAME;
  const logStreamName = key.replace(/\//g, '-');

  await cloudwatchlogs.createLogGroup({ logGroupName }).promise();
  await cloudwatchlogs.createLogStream({ logGroupName, logStreamName }).promise();

  const putLogEventsRequests = [];
  while (logEvents.length > 0) {
    const batch = logEvents.splice(0, 10000);
    putLogEventsRequests.push(
      cloudwatchlogs
        .putLogEvents({
          logGroupName,
          logStreamName,
          logEvents: batch,
        })
        .promise()
    );
  }

  await Promise.all(putLogEventsRequests);

  return {
    statusCode: 200,
    body: 'Logs forwarded to CloudWatch successfully!',
  };
};
