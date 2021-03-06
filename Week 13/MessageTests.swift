import XCTest
import TwilioChatClient
@testable import BeachGuardian

class MessageTests: XCTestCase ,TwilioChatClientDelegate{

    let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzA2OGVlYzEwMWU1MjBjMTQ1Njk4YjhlZGZjYzc4MGZlLTE1NTQzOTYyNzQiLCJncmFudHMiOnsiaWRlbnRpdHkiOiJGZW5nIiwiaXBfbWVzc2FnaW5nIjp7InNlcnZpY2Vfc2lkIjoiSVNlZmEwZGRiNGQ5ZDY0MTg4OWJmZmJjM2MxNGU0Zjc1ZCIsImVuZHBvaW50X2lkIjoiQ2hhdDE6RmVuZzo4MUZFMUY2My1FNjFBLTQ5RjgtQjk3Ny0xQUY0REE4MDc2OEMiLCJwdXNoX2NyZWRlbnRpYWxfc2lkIjoiQ1I1NjM1YTQ3Y2Y2YzIzMzExYTYwZTk2OTE4YTljZjVjMSJ9fSwiaWF0IjoxNTU0Mzk2Mjc0LCJleHAiOjE1NTQzOTk4NzQsImlzcyI6IlNLMDY4ZWVjMTAxZTUyMGMxNDU2OThiOGVkZmNjNzgwZmUiLCJzdWIiOiJBQzljOTU4MWQxMTU3ZjliOTE2ODgzNmM0YWFhZmVkYWI5In0.YSqaiZFGDS-5YSH28do3dqqpNk2JXOwrax_R-bkwzc0"
    var messageViewController: BeachGuardian.MessageViewController!
    var testClient: TCHManager = mockInstantiate()
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageViewController")
        messageViewController = vc as? BeachGuardian.MessageViewController
        messageViewController.manager = testClient
        _ = messageViewController.view
    }
    
    func test_if_messageViewController_hasBeen_loaded(){
        XCTAssertNotNil(messageViewController)
    }
    
    func test_instantiateClient_is_calls_chatClient(){
        
        class TwilioChatClientMock: ChatClient{
            
            static var chatClientCalled = false
            
            static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }
            
        }
        let manager = TCHManagerDelegate()
        manager.chatClient = TwilioChatClientMock.self
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        
        XCTAssertTrue(TwilioChatClientMock.chatClientCalled)
        
        
    }
    
    func test_instantiateClient_initializes_client(){
        
        class TwilioChatClientMock: ChatClient{
            
            static var givenCompletion:TCHTwilioClientCompletion?
            
            static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                givenCompletion = completion
            }
            
        }
        
        let manager = TCHManagerDelegate()
        manager.chatClient = TwilioChatClientMock.self
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        let client = TwilioChatClient()
        TwilioChatClientMock.givenCompletion!(TCHResult(),client)
        XCTAssertEqual(client,manager.client)
        
    }
    
    func testNib() {
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! ChatMessageCell
        
        view.setSelected(true, animated: true)
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view.chatCellBackgroudView.layer.cornerRadius, 10)
    }
    
    func test_ChatClient_MessagesAdded()
    {
        class MockTCHMessage : TCHMessage{
            override var author: String?{
                get {
                    return "Edward"
                }
                set{
                    self.author = newValue
                }
            }
            override var body: String?{
                get {
                    return "test"
                }
                set{
                    self.body = newValue
                }
            }
        }
        class MockTwilioChatClient: TwilioChatClient{
            
            static var chatClientCalled = false
            
            override static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }
            
            var channelsListCalled = false
            override func channelsList() -> TCHChannels? {
                channelsListCalled = true
                return TCHChannels()
            }
        }
        let mockClient = MockTwilioChatClient()
        let manager = TCHManagerDelegate()
        manager.client = mockClient
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        
        let mockGeneralChannel = MockGeneralChannel()
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController
        
        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        mockMessageViewController.scrollToBottomMessage()
        
        mockMessageViewController.chatClient(mockClient, channel: MockGeneralChannel(), messageAdded: TCHMessage())
        XCTAssertEqual(mockMessageViewController.messages.count, 1)
    }
    
    func testTableViewCellsDequeued_CellReturnedBlue()
    {
        class MockTCHChannels : TCHChannels{
            var result = TCHResult()
            var createChannelCalled = false
            override func createChannel(options: [String : Any] = [:], completion: TCHChannelCompletion? = nil) {
                createChannelCalled = true
                completion!(result, MockGeneralChannel())
            }
        }
        class MockTwilioChatClient: TwilioChatClient{

            static var chatClientCalled = false

            override static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }

            var channelsListCalled = false
            override func channelsList() -> TCHChannels? {
                channelsListCalled = true
                return TCHChannels()
            }
        }
        class MockTCHMessage : TCHMessage{
            override var author: String?{
                get {
                    return "Not Feng"
                }
                set{
                    self.author = newValue
                }
            }
            override var body: String?{
                get {
                    return "test"
                }
                set{
                    self.body = newValue
                }
            }
        }

        let mockClient = MockTwilioChatClient()
        let manager = TCHManagerDelegate()
        manager.client = mockClient
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        let mockGeneralChannel = MockGeneralChannel()
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController

        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        mockMessageViewController.scrollToBottomMessage()
        _ = MockTCHChannels()
        let indexPath = IndexPath(row: 0, section: 0)
        let tchMessage = MockTCHMessage()
        messageViewController.messages.append(tchMessage)
        let returnCell = messageViewController.tableView(mockTableView, cellForRowAt: indexPath) as! ChatMessageCell
        XCTAssertEqual(returnCell.chatCellBackgroudView.backgroundColor, UIColor.blue)
    }

    func testTableViewCellsDequeued_CellReturnedRed()
    {
        class MockTCHChannels : TCHChannels{
            var result = TCHResult()
            var createChannelCalled = false
            override func createChannel(options: [String : Any] = [:], completion: TCHChannelCompletion? = nil) {
                createChannelCalled = true
                completion!(result, MockGeneralChannel())
            }
        }
        class MockTwilioChatClient: TwilioChatClient{

            static var chatClientCalled = false

            override static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }

            var channelsListCalled = false
            override func channelsList() -> TCHChannels? {
                channelsListCalled = true
                return TCHChannels()
            }
        }
        class MockTCHMessage : TCHMessage{
            override var author: String?{
                get {
                    return "Feng"
                }
                set{
                    self.author = newValue
                }
            }
            override var body: String?{
                get {
                    return "test"
                }
                set{
                    self.body = newValue
                }
            }
        }

        let mockClient = MockTwilioChatClient()
        let manager = TCHManagerDelegate()
        manager.client = mockClient
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        let mockGeneralChannel = MockGeneralChannel()
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController

        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        mockMessageViewController.scrollToBottomMessage()
        _ = MockTCHChannels()
        let indexPath = IndexPath(row: 0, section: 0)
        let tchMessage = MockTCHMessage()
        messageViewController.messages.append(tchMessage)
        let returnCell = messageViewController.tableView(mockTableView, cellForRowAt: indexPath) as! ChatMessageCell
        XCTAssertEqual(returnCell.chatCellBackgroudView.backgroundColor, UIColor.red)
    }
    
    func test_ChatClient_SyncStatusUpdated_ChannelJoined(){
        class MockTwilioChatClient: TwilioChatClient{
            
            static var chatClientCalled = false
            
            override static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }
            
            var channelsListCalled = false
            override func channelsList() -> TCHChannels? {
                channelsListCalled = true
                return TCHChannels()
            }
        }
        let mockClient = MockTwilioChatClient()
        let manager = TCHManagerDelegate()
        manager.client = mockClient
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        messageViewController.chatClient(mockClient, synchronizationStatusUpdated: TCHClientSynchronizationStatus(rawValue: 2)!)
        XCTAssertEqual(mockClient.channelsListCalled, true)
    }
    
    func test_GetChannelList_ChannelsListReturned(){
        class MockTwilioChatClient: TwilioChatClient{
            
            static var chatClientCalled = false
            
            override static func chatClient(withToken: String, properties: TwilioChatClientProperties?, delegate: TwilioChatClientDelegate?, completion: @escaping TCHTwilioClientCompletion){
                chatClientCalled = true
            }
            
            var channelsListCalled = false
            override func channelsList() -> TCHChannels? {
                channelsListCalled = true
                return TCHChannels()
            }
        }
        let mockClient = MockTwilioChatClient()
        let manager = TCHManagerDelegate()
        manager.client = mockClient
        let container: ()-> Void = {}
        manager.instantiateClient(with: "sample",delegate: messageViewController, completion: container)
        
        _ = messageViewController.getChannelList(client: mockClient)
        XCTAssertEqual(mockClient.channelsListCalled, true)
    }
    
    func test_CreateChannel(){
        class MockTCHChannels : TCHChannels{
            var result = TCHResult()
            var createChannelCalled = false
            override func createChannel(options: [String : Any] = [:], completion: TCHChannelCompletion? = nil) {
                createChannelCalled = true
                completion!(result, MockGeneralChannel())
            }
        }
        let mockGeneralChannel = MockGeneralChannel()
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController
       
        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        mockMessageViewController.scrollToBottomMessage()
        let mockTCHChannels = MockTCHChannels()
        mockMessageViewController.createChannel(channelList: mockTCHChannels)
        XCTAssertEqual(mockTCHChannels.createChannelCalled, true)
    }
    
    func test_LoadMessages()
    {
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController
        let mockGeneralChannel = MockGeneralChannel()
        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        //mockMessageViewController.loadViewIfNeeded()
        mockMessageViewController.scrollToBottomMessage()
        mockMessageViewController.loadMessages(channel: mockGeneralChannel)
        XCTAssertTrue(mockGeneralChannel.messages.result.isSuccessful())
    }
    
    func test_JoinChannel(){
        let mockMessageViewController = MockMessageViewController()
        let _ : MessageViewController = mockMessageViewController
        let mockGeneralChannel = MockGeneralChannel()
        mockMessageViewController.generalChannel = mockGeneralChannel
        let mockTableView = mockUITableView()
        mockMessageViewController.tableView = mockTableView
        //mockMessageViewController.loadViewIfNeeded()
        mockMessageViewController.scrollToBottomMessage()
        mockMessageViewController.joinChannel(channel: mockGeneralChannel)
    }
    
    func test_SendMessagePressed(){
    
        let mockGeneralChannel = MockGeneralChannel()
        messageViewController.generalChannel = mockGeneralChannel
        
        let someFrame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
        messageViewController.messageTextField = UITextField(frame: someFrame)
        
        messageViewController.sendMessagePressed(UIButton())
        XCTAssertTrue(mockGeneralChannel.messages.result.isSuccessful())
        
    }
    
    func test_ScrollToBottomMessageNoMessage_Returns(){
        
        let mockTableView = mockUITableView()
        messageViewController.tableView = mockTableView
        messageViewController.loadViewIfNeeded()
        messageViewController.scrollToBottomMessage()
        XCTAssertEqual(mockTableView.scrollBoolCalled, false)
    }
    
    func test_ViewTapped_EndsEditing(){
        messageViewController.viewTapped()
        XCTAssertEqual(messageViewController.messageTextField.isEditing, false)
    }
    
    func test_ScrollToBottomMessage_atBottomMessageIndex(){
        
        let mockTableView = mockUITableView()
        messageViewController.tableView = mockTableView
        messageViewController.messages = [TCHMessage]()
        messageViewController.messages.append(TCHMessage())
        messageViewController.loadViewIfNeeded()
        messageViewController.scrollToBottomMessage()
        XCTAssertEqual(mockTableView.scrollBoolCalled, true)
    }
    
    func test_ConfigureTableView_SepatorStyle_Is_none(){
        let mockUITableView = UITableView()
        let tableView = mockUITableView
        messageViewController.tableView = tableView
        messageViewController.configureTableView()
        XCTAssertEqual(messageViewController.tableView.separatorStyle, .none)
    }
    
    func test_TextFieldDidEndEditing_HeightConstraintReduced(){
        messageViewController.textFieldDidEndEditing(UITextField())
        XCTAssertEqual(messageViewController.heightConstraint.constant, 3)
    }
    
    func test_TextFieldDidEndEditing_HeightConstraintIncreased(){
        messageViewController.textFieldDidBeginEditing(UITextField())
        XCTAssertEqual(messageViewController.heightConstraint.constant, 308)
    }
}

class mockInstantiate: TCHManager {
    func instantiateClient(with token: String, delegate: TwilioChatClientDelegate, completion: instantiationCompletion) {
        self.client = TwilioChatClient()
    }
    
    var client: TwilioChatClient?
}

class mockUITableView : UITableView
{
    var scrollBoolCalled: Bool = false
    override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool){
        scrollBoolCalled = true
    }
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let chatMessageCell = ChatMessageCell()
        chatMessageCell.chatCellBackgroudView = UIView()
        chatMessageCell.messageLabel = UILabel()
        chatMessageCell.authorMessage = UILabel()
        return chatMessageCell
    }
}

class MockGeneralChannel : TCHChannel{
    override var messages : MockTCHMessages{
        get {
            return MockTCHMessages()
        }
        set{
            self.messages = newValue
        }
    }
    
    override func join(completion: TCHCompletion? = nil) {        completion!(TCHResult())
    }
    
    override var synchronizationStatus: TCHChannelSynchronizationStatus{
        get {
            return TCHChannelSynchronizationStatus(rawValue: 3)!
        }
        set{
            self.synchronizationStatus = newValue
        }
    }
    
    override func setUniqueName(_ uniqueName: String?, completion: TCHCompletion? = nil) {
        completion!(TCHResult())
    }
}

class MockTCHMessages : TCHMessages {
    var sendMessageCalled : Bool = false
    var result = TCHResult()
    override func sendMessage(with options: TCHMessageOptions, completion: TCHMessageCompletion? = nil) {
        sendMessageCalled = true
        completion!(result, TCHMessage())
    }
    
    override func getLastWithCount(_ count: UInt, completion: @escaping TCHMessagesCompletion) {
        var messages = [TCHMessage]()
        messages.append(TCHMessage())
        completion(TCHResult(),messages)
    }
}

class MockMessageViewController : MessageViewController{
    var tableViewCellForRowCalled = false
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        tableViewCellForRowCalled = true
        return UITableViewCell()
    }
}
