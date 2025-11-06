const fs = require('fs');
const readline = require('readline');
const { google } = require('googleapis');

// ========== Settings ==========
const CALENDAR_ID = 'primary'; // or set to your calendar's email
const EVENT_TITLE_PREFIX = 'Gatsby';
// ==============================

const SCOPES = ['https://www.googleapis.com/auth/calendar.events'];
const TOKEN_PATH = 'token.json';

function authorize(credentials, callback) {
  const { client_secret, client_id, redirect_uris } = credentials.installed;
  const oAuth2Client = new google.auth.OAuth2(
    client_id, client_secret, redirect_uris[0]
  );
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

async function findNextAdidasNumber(calendar) {
  // Search for latest 100 Adidas events on calendar (could use timeMin/timeMax for efficiency)
  const now = new Date();
  const oneYearAgo = new Date(now.getTime() - 366 * 24 * 60 * 60 * 1000);
  let pageToken = null;
  let maxNumber = 0;

  do {
    const res = await calendar.events.list({
      calendarId: CALENDAR_ID,
      q: EVENT_TITLE_PREFIX,
      timeMin: oneYearAgo.toISOString(),
      singleEvents: true,
      orderBy: "startTime",
      pageToken: pageToken,
      maxResults: 100
    });

    const events = res.data.items || [];
    for (const event of events) {
      const title = event.summary || "";
      // Match "Adidas 12", "Adidas 13", etc.
      const match = title.match(new RegExp(EVENT_TITLE_PREFIX + ' (\\d+)$', 'i'));
      if (match) {
        const num = parseInt(match[1], 10);
        if (num > maxNumber) maxNumber = num;
      }
    }
    pageToken = res.data.nextPageToken;
  } while (pageToken);

  return maxNumber + 1;
}

async function addAdidasEvent(auth) {
  const calendar = google.calendar({ version: 'v3', auth });

  const nextNumber = await findNextAdidasNumber(calendar);
  const title = `${EVENT_TITLE_PREFIX} ${nextNumber}`;

  const event = {
    summary: title,
    start: { date: new Date().toISOString().split('T')[0] },
    end: { date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0] }
  };

  calendar.events.insert(
    {
      calendarId: CALENDAR_ID,
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

fs.readFile('calendar.json', (err, content) => {
  if (err) return console.log('Error loading client secret file:', err);
  authorize(JSON.parse(content), (auth) => {
    addAdidasEvent(auth);
  });
});