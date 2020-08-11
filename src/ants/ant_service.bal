import ballerina/http;
import ballerina/io;
import ballerina/log;

http:Client firstNeighbourEP = new ("http://localhost:9091", {httpVersion: "2.0"});

listener http:Listener ownerEP = new (6549,
    config = {httpVersion: "2.0"});


service iotService on ownerEP {

}