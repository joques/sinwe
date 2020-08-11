import ballerina/grpc;
import ballerina/http;
import ballerina/io;
import ballerina/log;


SwarmBlockingClient iotRep = new("http://localhost:10000");
http:Client headAntEP = new ("http://localhost:9091", {httpVersion: "2.0"});

listener http:Listener swarmEP = new (6549,
    config = {httpVersion: "2.0"});

@http: ServiceConfig {
	basePath: "/iotservice"
}

service iotService on swarmEP {

	@http: ResourceConfig {
		methods: ["POST"],
		path: "/join",
		consumes: ["application/json"]
	}

	resource function joinSwarm(http:Caller caller, http:Request req) {
		json joinInfo = req.getJsonPayload();

		int part1 = <@untainted>joinInfo.ip_part1;
		int part2 = <@untainted>joinInfo.ip_part2;
		int part3 = <@untainted>joinInfo.ip_part3;
		int part4 = <@untainted>joinInfo.ip_part4;
		int port = <@untainted>joinInfo.port_number;

		var http:Response joinResp = new;

		IoTProcess curProc = {
			ip_part1: part1,
			ip_part2: part2;
			ip_part3: part3,
			ip_part4: part4,
			port_number: port
		};

		var joinRPCResp = iotRep->JoinSwarm(cur_proc);

		if (joinRPCResp is grpc:error) {
			joinResp.statusCode = 500;
			joinResp.setPayload("Cannot find the details of the join request");
		} else {
			string device_id = joinRPCResp.device_id;
			joinResp.setPayload({device: device_id});
		}

		var joinRes = caller -> respond(joinResp);
		if (joinRes is error) {
			log:printError(joinRes.reason(), joinRes);
		}
	}

	@http: ResourceConfig {
		methods: ["POST"],
		path: "/suspect",
		consumes: ["application/json"]
	}

	resource function suspectDevice(http:Caller caller, http:Request req) {
		string[] theDevices = <@untainted> req.getJsonPayload().device_ids;

		DeviceGroup devGrp = {
			device_ids: theDevices
		};

		var http:Response suspectResp = new;

		var suspectRPCResp = iotRep->SuspectDevice(devGrp);

		if (suspectRPCResp is grpc:error) {
			suspectResp.statusCode = 500;
			suspectResp.setPayload("Error! Cannot report suspected device");
		}
		else {
			suspectResp.setPayload("Success! Suspected device reported...");
		}

		var susRes = caller->respond(suspectResp);
		if (susRes is error) {
			log:printError(susRes.reason(), susRes);
		}
	}

	@http: ResourceConfig {
		methods: ["POST"],
		path: "/resurrect",
		consumes: ["application/json"]
	}

	resource function resurrectDevice(http:Caller caller, http:Request req) {
		string[] allDevices = <@untainted> req.getJsonPayload().device_ids;

		DeviceGroup devGrp = {
			device_ids: allDevices
		};

		var http:Response resurrectResp = new;

		var resurrectRPCResp = iotRep->ResurrectDevice(devGrp);

		if (resurrectRPCResp is grpc:error) {
			resurrectResp.statusCode = 500;
			resurrectResp.setPayload("Error! Cannot resurrect previously suspected device");
		}
		else {
			resurrectResp.setPayload("Success! Device resurrected");
		}

		var resurrectRes = caller->respond(resurrectResp);

		if(resurrectRes is error) {
			log:printError(resurrectRes.reason(), resurrectRes);
		}
	}

	@http: ResourceConfig {
		methods: ["POST"],
		path: "/deliver",
		consumes: ["application/json"]
	}

	resource function deliverMessage(http:Caller caller, http:Request req) {
		json msg = req.getJsonPayload();
		string messageID = <@untainted> msg.message_id;
		string messageSender = <@untainted> msg.sender;
		string messageTopic = <@untainted> msg.topic;
		string messageContent = <@untainted> msg.content;
		string[] thePath = <@untainted> msg.path_component;

		SwarmMessage swMessage = {
			swarm_ident: messageID,
			sender: messageSender,
			topic: messageTopic,
			content: messageContent,
			path_element: thePath
		};

		var http:Response deliverResp = new;

		var deliverRPCResp = iotRep->DeliverMessage(swMessage);

		if (deliverRPCResp is grpc:error) {
			deliverResp.statusCode = 500;
			deliverResp.setPayload("Error! Cannot deliver message");
		}
		else {
			deliverResp.setPayload("Success! Message delivered");
		}

		var deliverRes = caller->respond(deliverResp);
		if (deliverRes is error) {
			log:printError(deliverRes.reason(), deliverRes);
		}
	}

	@http: ResourceConfig {
		methods: ["GET"],
		path: "/start"
	}

	resource function startForwarding(http:Caller caller, http:Request req) {
		var http:Response startResp = new;
		var startRPCResp = iotRep->StartCommunication(SwarmServerListener);

		if (startRPCResp is grpc:error) {
			startResp.statusCode = 500;
			startResp.setPayload("Error! Cannot start message submission");
		}
		else {
			startResp.setPayload("Success! Started the message submission from the server");
		}

		var startRes = caller->respond(startResp);
		if(startRes is error) {
			log:printError(startRes.reason(), startRes);
		}
	}
}

service SwarmServerListener = service {
	resource function onMessage(SwarmMessage msg) {
		//might have to convert msg into a json object
		http:Request msgReq = new;
		msgReq.setPayload(msg);
		resp = headAntEP->post("/new/message", msgReq);
		if (resp is error) {
			log:printError(resp.reason(), resp);
		}
	}

	resource function onError(error err) {
		log:printError(err.reason(), err);
	}

	resource function onComplete() {
		io:println("Message submission completed±");
	}
}