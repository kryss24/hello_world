// import Debug "mo:base/Debug";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Text "mo:base/Text";

actor RentalContract {
    
    // Définition des types de données
    type UserId = Text;
    type UserType = { #Locataire; #Bailleur };
    type PaymentStatus = { #Paid; #Pending; #Late };
    
    type User = {
        id: UserId;
        userType: UserType;
        name: Text;
        email: Text;
        password: Text;
        verified: Bool;
        paymentHistory: [PaymentRecord];
    };
    
    type PaymentRecord = {
        date: Time.Time;
        amount: Nat;
        status: PaymentStatus;
    };

    type ApartmentId = Text;
    type ApartmentStatus = { #Pending; #Free };

    type Apartment = {
        id: ApartmentId;
        address: Text;
        statut: ApartmentStatus;
    };

    type ContractId = Text;
    
    type Contract = {
        id: ContractId;
        landlordId: UserId;
        tenantId: UserId;
        apartementId: ApartmentId;
        details: Text;
        payments: [PaymentRecord];
    };

    // Base de données des utilisateurs et des contrats
    private var users = HashMap.HashMap<UserId, User>(10, Text.equal, Text.hash);
    // Base de données des contrats
    private var contracts = HashMap.HashMap<ContractId, Contract>(10, Text.equal, Text.hash);
    // Base de données des contrats
    private var apartments = HashMap.HashMap<ApartmentId, Apartment>(10, Text.equal, Text.hash);

    //Constructor
    public func RentalContract() {

    };

    //Fonction de Connexion
    public func connectUser(id: UserId) : async Bool {
        if(users.get(id) == null)
            return false;
        return true;
    };

    // Fonction pour enregistrer un nouvel utilisateur
    public func registerUser(id: UserId, userType: UserType, name: Text, email: Text, password: Text) : async Bool {
        if (users.get(id) != null) {
            return false;  // L'utilisateur existe déjà
        };
        let newUser = {
            id = id;
            userType = userType;
            name = name;
            email = email;
            password = password;
            verified = false;
            paymentHistory = [];
        };
        users.put(id, newUser);
        return true;
    };

    // Fonction pour vérifier l'identité de l'utilisateur
    public func verifyUser(id: UserId) : async Bool {
        switch (users.get(id)) {
            case (?user) {
                let updatedUser = {
                    id = user.id;
                    userType = user.userType;
                    name = user.name;
                    email = user.email;
                    password = user.password;
                    verified = true;
                    paymentHistory = user.paymentHistory;
                };
                users.put(id, updatedUser);
                return true;
            };
            case null return false;  // Utilisateur non trouvé
        };
    };

    // Fonction pour ajouter un enregistrement de paiement
    public func addPaymentRecord(id: UserId, record: PaymentRecord) : async Bool {
        switch (users.get(id)) {
            case (?user) {
                let updatedUser = {
                    id = user.id;
                    userType = user.userType;
                    name = user.name;
                    email = user.email;
                    password = user.password;
                    verified = user.verified;
                    paymentHistory = Array.append(user.paymentHistory, [record]);
                };
                users.put(id, updatedUser);
                return true;
            };
            case null return false;  // Utilisateur non trouvé
        };
    };

    // Fonction pour obtenir l'historique des paiements d'un utilisateur
    public query func getPaymentHistory(id: UserId) : async ?[PaymentRecord] {
        switch (users.get(id)) {
            case (?user) return ?user.paymentHistory;
            case null return null;  // Utilisateur non trouvé
        };
    };

    // Fonction pour vérifier si un utilisateur est vérifié
    public query func isUserVerified(id: UserId) : async Bool {
        switch (users.get(id)) {
            case (?user) return user.verified;
            case null return false;  // Utilisateur non trouvé
        };
    };

    public func createContract(contractId: ContractId, landlordId: UserId, tenantId: UserId, apartementId: ApartmentId, details: Text, payments: [PaymentRecord]) : async Bool {
        if (contracts.get(contractId) != null) {
            return false;  // Le contrat existe déjà
        };
        let contract = {
            id = contractId;
            landlordId = landlordId;
            tenantId = tenantId;
            apartementId = apartementId;
            details = details;
            payments = payments;
        };
        contracts.put(contractId, contract);
        return true;
    };

    // Fonction pour mettre à jour un contrat de location
    public func updateContract(contractId: ContractId, details: Text) : async Bool {
        switch (contracts.get(contractId)) {
            case (?contract) {
                let updatedContract = {
                    id = contract.id;
                    landlordId = contract.landlordId;
                    tenantId = contract.tenantId;
                    apartementId = contract.apartementId;
                    details = details;
                    payments = contract.payments;
                };
                contracts.put(contractId, updatedContract);
                return true;
            };
            case null return false;  // Contrat non trouvé
        };
    };

    // Fonction pour ajouter un paiement à un contrat
    public func addPayment(contractId: ContractId, amount: Nat, dueDate: Time.Time) : async Bool {
        switch (contracts.get(contractId)) {
            case (?contract) {
                let newPayment = {
                    amount = amount;
                    date = dueDate;
                    status = #Pending;
                };
                let updatedPayments = Array.append(contract.payments, [newPayment]);
                let updatedContract = {
                    id = contract.id;
                    landlordId = contract.landlordId;
                    tenantId = contract.tenantId;
                    apartementId = contract.apartementId;
                    details = contract.details;
                    payments = updatedPayments;
                };
                contracts.put(contractId, updatedContract);
                return true;
            };
            case null return false;  // Contrat non trouvé
        };
    };

    // Fonction pour vérifier les paiements et appliquer les pénalités
    public func checkPayments() : async () {
      let now = Time.now();
      var updatedContracts = HashMap.HashMap<ContractId, Contract>(10, Text.equal, Text.hash);

      for (contractId in contracts.keys()) {
          switch (contracts.get(contractId)) {
              case (?contract) {
                  let updatedPayments = Array.map<PaymentRecord, PaymentRecord>(contract.payments, func (payment : PaymentRecord) : PaymentRecord {
                if (payment.status == #Pending and payment.date < now) {
                    {
                        date = payment.date;
                        amount = payment.amount + (payment.amount * 10 / 100);  // 10% penalty
                        status = #Late;
                    }
                } else {
                    payment
                }
            });

                  let updatedContract = {
                      id = contract.id;
                      landlordId = contract.landlordId;
                      tenantId = contract.tenantId;
                      apartementId = contract.apartementId;
                      details = contract.details;
                      payments = updatedPayments;
                  };

                  updatedContracts.put(contractId, updatedContract);
              };
              case null {
                  // Handle the case where the contract is not found (unlikely in this scenario)
              };
          };
      };

      contracts := updatedContracts;
  };

    // Fonction pour obtenir les détails d'un contrat de location
    public query func getContract(contractId: ContractId) : async ?Contract {
        switch (contracts.get(contractId)) {
            case (?contract) return ?contract;
            case null return null;  // Contrat non trouvé
        };
    };

    //Creer un appartement
    public func createApartment(apartmentId: ApartmentId, address: Text) : async Bool {
        if (apartments.get(apartmentId) != null) {
            return false;  // L'appartement existe déjà
        };
        let apartment = {
            id = apartmentId;
            address = address;
            statut = #Free;
        };
        apartments.put(apartmentId, apartment);
        return true;
    };

};