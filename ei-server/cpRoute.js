const express = require('express');
const router = express.Router();

function cpRoute(db) {
  const handleCloudpickResponse = (userId) => {
    // Perform actions based on Cloudpick response
    console.log(`Cloudpick response received for user with ID: ${userId}`);
  };

  // Route handler for /verify_qrcode
  router.post('/verify_qrcode', async (req, res) => {
    try {
      const { qrCode, storeId } = req.body;

      // Check if qrCode and storeId are defined
      if (!qrCode || !storeId) {
        return res.status(400).json({
          code: '1002',
          message: 'Invalid parameters',
        });
      }

      // Query Firestore for the user with the given QR code and store ID
      const querySnapshot = await db.collection('Users')
        .where('qrCode', '==', qrCode)
        .where('storeId', '==', storeId)
        .get();

      if (querySnapshot.empty) {
        // User not found in Firestore
        return res.json({
          code: '1001',
          message: 'User not found',
        });
      }

      // Retrieve the user ID from the Firestore document
      const userId = querySnapshot.docs[0].data().userId;

      // Respond with success and the user ID
      const response = {
        code: '0000',
        message: 'Success',
        userId,
      };

      // Example: Handle the Cloudpick response (adjust as needed)
      handleCloudpickResponse(userId);

      res.json(response);
    } catch (error) {
      console.error('Error querying Firestore:', error);

      // Handle error and respond with error details
      res.status(500).json({
        code: '5000',
        message: 'Internal server error',
        errorDetails: error.message,
      });
    }
  });

  // Route handler for /receive_cart
  router.post('/receive_cart', async (req, res) => {
    try {
      const { storeId, outUserId, cpCartId, builtAt, items } = req.body;

      // Check if required parameters are defined
      if (!storeId || !outUserId || !cpCartId || !builtAt || !items) {
        return res.status(400).json({
          code: '1002',
          message: 'Invalid parameters for cart information',
        });
      }

      // Reference to the user document
      const userDocRef = db.collection('Users').doc(outUserId);

      // Reference to the "cartTransactions" subcollection
      const cartTransactionsRef = userDocRef.collection('cartTransactions');

      // Add a new document for the current cart transaction
      const newTransactionRef = await cartTransactionsRef.add({
        storeId,
        cpCartId,
        builtAt,
        items,
    });

      // Respond with success
      res.json({
        code: '0000',
        message: 'Success',
        transactionId: newTransactionRef.id,
      });
    } catch (error) {
      console.error('Error processing cart information:', error);

      // Handle error and respond with error details
      res.status(500).json({
        code: '5000',
        message: 'Internal server error',
        errorDetails: error.message,
      });
    }
  });

  // Route handler for /empty_cart
  router.post('/empty_cart', async (req, res) => {
    try {
      const { storeId, outUserId, cpCartId, builtAt } = req.body;

      // Check if required parameters are defined
      if (!storeId || !outUserId || !cpCartId || !builtAt) {
        return res.status(400).json({
          code: '1002',
          message: 'Invalid parameters for empty cart information',
        });
      }

      // Reference to the user document
      const userDocRef = db.collection('Users').doc(outUserId);

      // Reference to the "emptyCartTransactions" subcollection
      const emptyCartTransactionsRef = userDocRef.collection('emptyCartTransactions');

      // Add a new document for the empty cart transaction
      const newTransactionRef = await emptyCartTransactionsRef.add({
        storeId,
        cpCartId,
        builtAt,
      });

      // Respond with success
      res.json({
        code: '0000',
        message: 'Success',
        transactionId: newTransactionRef.id,
      });
    } catch (error) {
      console.error('Error processing empty cart information:', error);

      // Handle error and respond with error details
      res.status(500).json({
        code: '5000',
        message: 'Internal server error',
        errorDetails: error.message,
      });
    }
  });

  return router;
}

module.exports = cpRoute;
