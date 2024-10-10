importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyAABLBBksiKmh72rBTBEzL0Qh1_RD3NUD8",
  authDomain: "book-my-coolie-82e3c.firebaseapp.com",
  projectId: "book-my-coolie-82e3c",
  storageBucket: "book-my-coolie-82e3c.appspot.com",
  messagingSenderId: "266668166073",
  appId: "1:266668166073:web:84f260b6f4970f48e00468",
  measurementId: "G-305ZHE7MN9"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message: ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: payload.notification.icon,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
