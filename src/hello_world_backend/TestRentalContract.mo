// import RentalContract "./RentalContract";

// actor TestRentalContract  {
//   public query func runTests() : async () {
//         let contract = RentalContract.RentalContract();

//         // Test 1: Enregistrement d'un utilisateur
//         let userRegistered = await contract.registerUser("user1", #Locataire, "Alice", "alice@example.com");
//         assert(userRegistered == true, "L'enregistrement de l'utilisateur a échoué");

//         // Test 2: Vérification de l'utilisateur
//         let userVerifiedBefore = await contract.isUserVerified("user1");
//         assert(userVerifiedBefore == false, "L'utilisateur ne devrait pas être vérifié");

//         let userVerified = await contract.verifyUser("user1");
//         assert(userVerified == true, "La vérification de l'utilisateur a échoué");

//         let userVerifiedAfter = await contract.isUserVerified("user1");
//         assert(userVerifiedAfter == true, "L'utilisateur devrait être vérifié");

//         // Test 3: Ajout d'un enregistrement de paiement
//         let paymentAdded = await contract.addPaymentRecord(
//             "user1",
//             {
//                 date = Time.now();
//                 amount = 1000;
//                 status = #Paid;
//             }
//         );
//         assert(paymentAdded == true, "L'ajout de l'enregistrement de paiement a échoué");

//         // Test 4: Récupération de l'historique de paiement
//         let paymentHistory = await contract.getPaymentHistory("user1");
//         assert(paymentHistory != null and Array.size(?paymentHistory) > 0, "L'historique des paiements devrait contenir au moins un enregistrement");

//         Debug.print("Tous les tests ont réussi !");
//     };
// };
