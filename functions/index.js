const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot, context)=>{
        console.log("follower created ", snapshot.id);

        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const followedUserPostsRef = admin.firestore()
                                .collection('sharedMovies')
                                .doc(userId)
                                .collection('sharedMovies');

        const timelinePostRef = admin.firestore()
                                .collection('timeline')
                                .doc(followerId)
                                .collection('timelinePosts');


        const querySnapshot = await followedUserPostsRef.get();

        querySnapshot.forEach(doc =>{
            if(doc.exists){
                const postId = doc.id;
                const postData = doc.data();
                timelinePostRef.doc(postId).set(postData);
            }
        });
    });

    exports.onDeleteFollower = functions.firestore
            .document("/followers/{userId}/userFollowers/{followerId}")
            .onDelete(async (snapshot, context)=>{
        console.log("follower deleted ", snapshot.id);

        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const timelinePostRef = admin.firestore()
                                        .collection('timeline')
                                        .doc(followerId)
                                        .collection('timelinePosts')
                                        .where("ownerId", "==", userId);

        const querySnapshot = await timelinePostRef.get();
        querySnapshot.forEach(doc =>{
            if(doc.exists){
                doc.ref.delete();
            }
        });



     });
