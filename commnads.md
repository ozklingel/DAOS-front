C:\Android\platform-tools\adb.exe reverse tcp:8080 tcp:8080

flutter run `
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1 `
  --dart-define=GOOGLE_SERVER_CLIENT_ID=45773018634-5cb346f839msllrvp01cqfmfiva57tc6.apps.googleusercontent.com