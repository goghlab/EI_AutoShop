const express = require('express');
const router = express.Router();
const axios = require('axios');
const bodyParser = require('body-parser');
const apiKey = '30ZlTFFc/DFSqCkjsvMDyGjTm3hOGV4YFWqf1z3inv8=';
const admin = require('firebase-admin');

const headers = {
  'Content-Type': 'application/json', // Updated Content-Type header
  Authorization: `API-KEY ${apiKey}`,
  Referer: 'https://payment.everything-intelligence.com',
};

router.post('/initiate-payment', async (req, res) => {
  try {
    const { cartId, totalAmount } = req.body;

    // Log request parameters
    console.log('Received request body:', req.body);

    if (!cartId || !totalAmount) {
      console.log('Invalid parameters for payment initiation.');
      return res.status(400).json({
        code: '1002',
        message: 'Invalid parameters for payment initiation',
      });
    }

    // Convert cartId to custom_id
    const customId = cartId;

    // Construct the data object to be sent in the POST request to Yeepay
    const requestData = {
      amount: totalAmount,
      currency: 'HKD',
      return_url: 'https://www.everything-intelligence.com/',
      notify_url: 'https://payment.everything-intelligence.com/paymentdetail',
      custom_id: customId,
    };

    // Make the request to create the online payment checkout link
    const createLinkResponse = await axios.post(
      'https://api-staging.yedpay.com/v1/online-payment',
      requestData,
      {
        headers,
      }
    );

    // Log the response from create-online-payment-checkout-link
    console.log('Create online payment response:', createLinkResponse.data);

    // Extract relevant information from the response
    const { success, data, message, status } = createLinkResponse.data;

    // Check if the request was successful
    if (success) {
      const { token = data?.token, expired_at, checkout_url } = data;

      if (token) {
        // Construct the response object based on Yeepay's response
        const response = {
          code: '0000',
          message: 'Success',
          cartId,
          totalAmount,
          token,
          expired_at,
          checkout_url,
        };

        res.json(response);
      } else {
        // Handle error and respond with error details
        const response = {
          code: '5000',
          message: message || 'Internal server error during checkout',
          status: status || 500,
        };

        res.status(500).json(response);
      }
    } else {
      // Handle error and respond with error details
      const response = {
        code: '5000',
        message: message || 'Internal server error during checkout',
        status: status || 500,
      };

      res.status(500).json(response);
    }
  } catch (error) {
    console.error('Error initiating payment:', error);

    const response = {
      code: '5000',
      message: 'Internal server error',
      errorDetails: error.message,
    };

    res.status(500).json(response);
  }
});

router.post('/paymentdetail', bodyParser.urlencoded({ extended: true }), async (req, res) => {
  try {
    // Log request body
    console.log('Received request body:', req.body);

    const { success, request_type, transaction } = req.body;

    // Log the entire transaction object
    console.log('Payment details received:', transaction);

    // Log specific details
    console.log('Payment details received - Cart ID:', transaction.custom_id);
    console.log('Total Amount:', transaction.amount);
    console.log('Currency:', transaction.currency);
    console.log('Payment Status:', transaction.status);

    // Check if the payment is successful
    if (transaction.status === 'paid') {
      // Log the response URL for the return endpoint
      const responseURL = `https://www.everything-intelligence.com/?id=${transaction.store_id || ''}&transaction_id=${transaction.transaction_id}&gateway_code=${transaction.gateway_code}&company_name=${transaction.company_name || ''}&amount=${transaction.amount}&currency=${transaction.currency}&custom_id=${transaction.custom_id}&status=${transaction.status}&payment_method=${transaction.payment_method}&paid_at=${transaction.paid_at}&email=${transaction.email || ''}&sign_type=${transaction.sign_type || ''}&sign=${transaction.sign || ''}`;

      console.log('Response URL for the return endpoint:', responseURL);

      // Update Firestore with payment status if not already updated
      const firestore = admin.firestore();

      // Query Firestore based on custom_id
      const cartTransactionQuery = firestore.collectionGroup('cartTransactions').where('custom_id', '==', transaction.custom_id);
      const cartTransactionDocs = await cartTransactionQuery.get();

      if (!cartTransactionDocs.empty) {
        // Update the 'paid' field to true for each matching document
        const updates = cartTransactionDocs.docs.map(doc => doc.ref.update({ paid: true }));
        await Promise.all(updates);
        console.log('Firestore updated successfully');
      } else {
        console.error('Document not found for custom_id:', transaction.custom_id);
      }

      // Send successful response
      res.status(200).json({ success: true });
      console.log('Sent successful response:', { success: true });
    } else {
      // If the payment is not successful, proceed with the normal response
      res.status(200).json({ success: true });
      console.log('Sent successful response:', { success: true });
    }
  } catch (error) {
    console.error('Error processing request:', error);
    res.status(500).json({ error: 'Internal server error' });
    console.error('Sent error response:', { error: 'Internal server error' });
  }
});

router.get('/initiate-payment-response', (req, res) => {
  res.json(initiatePaymentResponse);
});

module.exports = router;
