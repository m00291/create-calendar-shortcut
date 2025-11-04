const fs = require('fs');
const readline = require('readline');
const { google } = require('googleapis');

// Get nearest 5-min interval (rounded)
function getNearest5MinInterval(date) {
  const ms = 1000 * 60 * 5;
  const time = date.getTime();
  const remainder = time % ms;
  let nearest;
  if (remainder < ms / 2) {
    nearest = new Date(time - remainder);
  } else {
    nearest = new Date(time + (ms - remainder));
  }
  return nearest;
}

function buildEvent() {
  const now = new Date();
  const endTime = getNearest5MinInterval(now);
  const startTime = new Date(endTime.getTime() - 15 * 60 * 1000);
  return {
    summary: '💩',
    start: {
      dateTime: startTime.toISOString(),
      timeZone: 'UTC',
    },
    end: {
      dateTime: endTime.toISOString(),
      timeZone: 'UTC',
    },
  };
}

const SCOPES = ['https://www.googleapis.com/auth/calendar.events'];
const TOKEN_PATH = 'token.json';

function authorize(credentials, callback) {
  const { client_secret, client_id, redirect_uris } = credentials.installed;
  const oAuth2Client = new google.auth.OAuth2(
    client_id, client_secret, redirect_uris[0]);

  // Check if we have previously stored a token.
  fs.readFile(TOKEN_PATH, (err, token) => {
    if (err) return getAccessToken(oAuth2Client, callback);
    oAuth2Client.setCredentials(JSON.parse(token));
    callback(oAuth2Client);
  });
}

function getAccessToken(oAuth2Client, callback) {
  const authUrl = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
  });
  console.log('Authorize this app by visiting this url:', authUrl);
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  rl.question('Enter the code from that page here: ', (code) => {
    rl.close();
    oAuth2Client.getToken(code, (err, token) => {
      if (err) return console.error('Error retrieving access token', err);
      oAuth2Client.setCredentials(token);
      fs.writeFile(TOKEN_PATH, JSON.stringify(token), (err) => {
        if (err) return console.error(err);
        console.log('Token stored to', TOKEN_PATH);
      });
      callback(oAuth2Client);
    });
  });
}

function addEvent(auth) {
  const calendar = google.calendar({ version: 'v3', auth });
  const event = buildEvent();

  calendar.events.insert(
    {
      auth: auth,
      calendarId: 'primary',
      resource: event,
    },
    (err, event) => {
      if (err) {
        console.log('There was an error contacting the Calendar service: ' + err);
        return;
      }
      console.log('Event created: %s', event.data.htmlLink);
    }
  );
}

// Load client secrets from a local file.
fs.readFile('calendar.json', (err, content) => {
  if (err) return console.log('Error loading client secret file:', err);
  authorize(JSON.parse(content), addEvent);
});