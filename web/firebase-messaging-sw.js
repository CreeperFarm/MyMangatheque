importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: "AIzaSyBf9yqBoDJccYXmBW4vQhDQtnFJXwkRf7M",
  authDomain: "mymangatheque.firebaseapp.com",
  databaseURL: "https://mymangatheque-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "mymangatheque",
  storageBucket: "mymangatheque.appspot.com",
  messagingSenderId: "390944577899",
  appId: "1:390944577899:web:3c08cc5975878305f7142e",
  measurementId: "G-Y50ZXZX206"
});

firebase.messaging();
