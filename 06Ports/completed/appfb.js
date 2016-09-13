'use strict';
// Initialize Firebase
// var config = {
//   apiKey: "YOURAPIKEYHERE",
//   authDomain: "YOURAUTHDOMAINHERE",
//   databaseURL: "YOURURLHERE",
//   storageBucket: "",
// };

var app = firebase.initializeApp(config);
var database = app.database();
var CUSTOMERREFPATH = "customers"

function addCustomer(customer){
  var promise = database
    .ref(CUSTOMERREFPATH)
    .push(customer);
  return promise;
}

function updateCustomer(customer){
  var id = customer.id;
  var promise = database
    .ref(CUSTOMERREFPATH + "/" + id)
    .set(customer);
  return promise;
}

function deleteCustomer(customer){
  var id = customer.id;
  var promise = database
    .ref(CUSTOMERREFPATH + "/" + id)
    .remove();
  return promise;
}

function customerListener(){
  return database.ref(CUSTOMERREFPATH);
}
