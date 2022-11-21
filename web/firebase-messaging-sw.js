importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyDjX-R1rqLdTIFNt-SoiFsHZpgrFAIxoGE',
    appId: '1:699649133437:web:f538eb1f2470f116ae9a14',
    messagingSenderId: '699649133437',
    projectId: 'to-do-list-8505f',
    authDomain: 'to-do-list-8505f.firebaseapp.com',
    storageBucket: 'to-do-list-8505f.appspot.com',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});

messaging.onMessage(function(payload) {
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body, 
        icon: payload.notification.icon,        
    };
    console.log(notificationTitle,notificationOptions)

    if (!("Notification" in window)) {
        console.log("This browser does not support system notifications.");
    } else if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var notification = new Notification(notificationTitle,notificationOptions);
        notification.onclick = function(event) {
            event.preventDefault();
            window.open(payload.notification.click_action , '_blank');
            notification.close();
        }
    }
});