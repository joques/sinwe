import ballerina/grpc;

public type SwarmBlockingClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function JoinSwarm(IoTProcess req, grpc:Headers? headers = ()) returns ([IoTDevice, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("avlo.Swarm/JoinSwarm", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<IoTDevice>result, resHeaders];
        
    }

    public remote function SuspectDevice(DeviceGroup req, grpc:Headers? headers = ()) returns ([IoTDeviceStatus, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("avlo.Swarm/SuspectDevice", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<IoTDeviceStatus>result, resHeaders];
        
    }

    public remote function ResurrectDevice(DeviceGroup req, grpc:Headers? headers = ()) returns ([IoTDeviceStatus, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("avlo.Swarm/ResurrectDevice", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        
        return [<IoTDeviceStatus>result, resHeaders];
        
    }

    public remote function DeliverMessage(SwarmMessage req, grpc:Headers? headers = ()) returns (grpc:Headers|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("avlo.Swarm/DeliverMessage", req, headers);
        grpc:Headers resHeaders = new;
        [_, resHeaders] = payload;
        return resHeaders;
    }

    public remote function StartCommunication(service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        Empty req = {};
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/StartCommunication", req, msgListener, headers);
    }

};

public type SwarmClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientConfiguration? config = ()) {
        // initialize client endpoint.
        self.grpcClient = new(url, config);
        checkpanic self.grpcClient.initStub(self, "non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
    }

    public remote function JoinSwarm(IoTProcess req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/JoinSwarm", req, msgListener, headers);
    }

    public remote function SuspectDevice(DeviceGroup req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/SuspectDevice", req, msgListener, headers);
    }

    public remote function ResurrectDevice(DeviceGroup req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/ResurrectDevice", req, msgListener, headers);
    }

    public remote function StartCommunication(service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        Empty req = {};
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/StartCommunication", req, msgListener, headers);
    }

    public remote function DeliverMessage(SwarmMessage req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("avlo.Swarm/DeliverMessage", req, msgListener, headers);
    }

};

public type IoTProcess record {|
    int ip_part1 = 0;
    int ip_part2 = 0;
    int ip_part3 = 0;
    int ip_part4 = 0;
    int port_number = 0;
    
|};


public type IoTDevice record {|
    string device_id = "";
    IoTProcess? owner = ();
    IoTProcess[] neighbour = [];
    
|};


public type DeviceGroup record {|
    string[] device_id = [];
    
|};


public type IoTDeviceStatus record {|
    DeviceStatus? value = ();
    
|};

public type DeviceStatus "ACTIVE"|"SUSPECTED"|"LEFT";
public const DeviceStatus DEVICESTATUS_ACTIVE = "ACTIVE";
const DeviceStatus DEVICESTATUS_SUSPECTED = "SUSPECTED";
const DeviceStatus DEVICESTATUS_LEFT = "LEFT";


public type SwarmMessage record {|
    string swarm_ident = "";
    string sender = "";
    string topic = "";
    string content = "";
    string[] path_element = [];
    
|};


public type Empty record {|
    
|};



const string ROOT_DESCRIPTOR = "0A0B737761726D2E70726F746F120461766C6F1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F2299010A0A496F5450726F6365737312190A0869705F706172743118012001280552076970506172743112190A0869705F706172743218022001280552076970506172743212190A0869705F706172743318032001280552076970506172743312190A0869705F7061727434180420012805520769705061727434121F0A0B706F72745F6E756D626572180520012805520A706F72744E756D6265722280010A09496F54446576696365121B0A096465766963655F69641801200128095208646576696365496412260A056F776E657218022001280B32102E61766C6F2E496F5450726F6365737352056F776E6572122E0A096E65696768626F757218032003280B32102E61766C6F2E496F5450726F6365737352096E65696768626F7572222A0A0B44657669636547726F7570121B0A096465766963655F6964180120032809520864657669636549642280010A0F496F5444657669636553746174757312380A0576616C756518012001280E32222E61766C6F2E496F544465766963655374617475732E446576696365537461747573520576616C756522330A0C446576696365537461747573120A0A064143544956451000120D0A09535553504543544544100112080A044C4546541002229A010A0C537761726D4D657373616765121F0A0B737761726D5F6964656E74180120012809520A737761726D4964656E7412160A0673656E646572180220012809520673656E64657212140A05746F7069631803200128095205746F70696312180A07636F6E74656E741804200128095207636F6E74656E7412210A0C706174685F656C656D656E74180520032809520B70617468456C656D656E7432BB020A05537761726D12300A094A6F696E537761726D12102E61766C6F2E496F5450726F636573731A0F2E61766C6F2E496F544465766963652200123B0A0D5375737065637444657669636512112E61766C6F2E44657669636547726F75701A152E61766C6F2E496F544465766963655374617475732200123D0A0F52657375727265637444657669636512112E61766C6F2E44657669636547726F75701A152E61766C6F2E496F54446576696365537461747573220012440A125374617274436F6D6D756E69636174696F6E12162E676F6F676C652E70726F746F6275662E456D7074791A122E61766C6F2E537761726D4D65737361676522003001123E0A0E44656C697665724D65737361676512122E61766C6F2E537761726D4D6573736167651A162E676F6F676C652E70726F746F6275662E456D7074792200620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "swarm.proto":"0A0B737761726D2E70726F746F120461766C6F1A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F2299010A0A496F5450726F6365737312190A0869705F706172743118012001280552076970506172743112190A0869705F706172743218022001280552076970506172743212190A0869705F706172743318032001280552076970506172743312190A0869705F7061727434180420012805520769705061727434121F0A0B706F72745F6E756D626572180520012805520A706F72744E756D6265722280010A09496F54446576696365121B0A096465766963655F69641801200128095208646576696365496412260A056F776E657218022001280B32102E61766C6F2E496F5450726F6365737352056F776E6572122E0A096E65696768626F757218032003280B32102E61766C6F2E496F5450726F6365737352096E65696768626F7572222A0A0B44657669636547726F7570121B0A096465766963655F6964180120032809520864657669636549642280010A0F496F5444657669636553746174757312380A0576616C756518012001280E32222E61766C6F2E496F544465766963655374617475732E446576696365537461747573520576616C756522330A0C446576696365537461747573120A0A064143544956451000120D0A09535553504543544544100112080A044C4546541002229A010A0C537761726D4D657373616765121F0A0B737761726D5F6964656E74180120012809520A737761726D4964656E7412160A0673656E646572180220012809520673656E64657212140A05746F7069631803200128095205746F70696312180A07636F6E74656E741804200128095207636F6E74656E7412210A0C706174685F656C656D656E74180520032809520B70617468456C656D656E7432BB020A05537761726D12300A094A6F696E537761726D12102E61766C6F2E496F5450726F636573731A0F2E61766C6F2E496F544465766963652200123B0A0D5375737065637444657669636512112E61766C6F2E44657669636547726F75701A152E61766C6F2E496F544465766963655374617475732200123D0A0F52657375727265637444657669636512112E61766C6F2E44657669636547726F75701A152E61766C6F2E496F54446576696365537461747573220012440A125374617274436F6D6D756E69636174696F6E12162E676F6F676C652E70726F746F6275662E456D7074791A122E61766C6F2E537761726D4D65737361676522003001123E0A0E44656C697665724D65737361676512122E61766C6F2E537761726D4D6573736167651A162E676F6F676C652E70726F746F6275662E456D7074792200620670726F746F33",
        "google/protobuf/empty.proto":"0A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F120F676F6F676C652E70726F746F62756622070A05456D70747942540A13636F6D2E676F6F676C652E70726F746F627566420A456D70747950726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
        
    };
}

