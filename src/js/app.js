App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    // Load creators.
    // Ideally JSON should be auto-populated by a function
    $.getJSON('../creators.json', function(data) {                  // Get this asap ***********
      var creatorsRow = $('#creatorsRow');
      var creatorTemplate = $('#creatorTemplate');

      for (i = 0; i < data.length; i ++) {
        creatorTemplate.find('.panel-title').text(data[i].name);
        creatorTemplate.find('img').attr('src', data[i].picture);
        creatorTemplate.find('.btn-tip').attr('data-id', data[i].id);
        creatorTemplate.find('.btn-subscribe').attr('data-id', data[i].id);

        creatorsRow.append(creatorTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Ethreon.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var EthreonArtifact = data;
      App.contracts.Ethreon = TruffleContract(EthreonArtifact);
    
      // Set the provider for our contract
      App.contracts.Ethreon.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the adopted pets
      return App.markAdopted();                                             // Do a similar to get mark subscribed
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-subscribe', App.newSubscription(1));      // Add data-id instead of static number
    $(document).on('click', '.btn-tip', App.tipCreator(1));
  },

  markAdopted: function(adopters, account) {
    /*
     * Replace me...
     */
  },

  handleAdopt: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    var ethreonInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0];
    
      App.contracts.Ethreon.deployed().then(function(instance) {
        ethreonInstance = instance;
      
        // Execute adopt as a transaction by sending account
        return ethreonInstance.adopt(petId, {from: account});
      }).then(function(result) {
        return App.markAdopted();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
