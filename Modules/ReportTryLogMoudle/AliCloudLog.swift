import HandyJSON
import RxSwift
import Action
import SwiftyJSON

let AppVersion = "appVersion"
let Uuid = "uuid"
let System = "system"
let SystemVersion = "systemVersion"
let RequestUrl = "requestUrl"
let RequestParams = "requestParams"
let Phone = "phone"
let Response = "response"
let ErrorMsg = "errorMessage"
let socketStatusMsg = "socketStatusMsg"
let socketParams = "socketParams"
let Header = "header"

/// Log

@objcMembers class AliCloudLog: NSObject {
    /// 单例
    static let shared: AliCloudLog = AliCloudLog()
    /// 日志上报调用对象
    private var client: LOGClient!
    /// 网络监听
    private let networkManager: NetworkListenManager = NetworkListenManager(host: "www.uuabc.com")
    /// Log存储组
    private var logGroup = LogGroup(topic: "", source: Device.modelName)
    /// 是否开启日志上报
    var isEnable: Bool? = DefaultsTool.getValue(.logEnable){
        didSet {
            guard let enable = isEnable else {return}
            if enable {
                self.reloadLogClient()
            } else {
                self.stopLogTimeClient()
            }
        }
    }
    
    private let bag = DisposeBag()
    
    override init() {
        self.client = LOGClient(endPoint: DefaultsTool.getValue(.logPoint) ?? "", accessKeyID: "", accessKeySecret: "", projectName: "prd-ios-log", token: "", config: SLSConfig(connectType: .wifiOrwwan, cachable: true))
    }
    
    /// Json转换失败
    func putEnterJsonError(requestUrl: String, reponse: String, requestParams: [String:Any], header: String = "") {
        self.putEnterGroup(Content: "JsonError", Content: [RequestUrl: requestUrl, RequestParams: requestParams.toString(),Response: reponse, ErrorMsg: "JSON转换失败", Header: header])
    }
    
    /// 服务器错误
    func putEnterServiceError(requestUrl: String, reponse: String, errorMsg: String, requestParams: [String:Any], header: String = "") {
        self.putEnterGroup(Content: "serviceError", Content: [RequestUrl: requestUrl, RequestParams: requestParams.toString(), ErrorMsg: errorMsg, Response: reponse, Header: header])
    }
    
    /// 网络错误
    func putEnterNetworkError(error: Error, requestUrl: String, requestParams: [String:Any], header: String = "") {
        self.putEnterGroup(Content: "networkError", Content: [RequestUrl: requestUrl, RequestParams: requestParams.toString(), ErrorMsg: error.toString(), Header: header] )
    }
    
    /// Socket错误
    func putSocketError(params: [String:Any]) {
        self.putEnterGroup(Content: "socketError", Content: [Response: params.toString()])
    }
    
    /// 声网错误
    func putAgoraError(params: [String:Any]) {
        self.putEnterGroup(Content: "AgoraLog", Content: [Response: params.toString()])
    }
    
    /// 日志上报
    /// - Parameters:
    ///   - key: 对应日志Key名
    ///   - value: 日志主题内容
    private func putEnterGroup(Content key: String, Content value: [String : String]) {
        guard isEnable ?? false else { return }
        let log = Log()
        var putDic:[String:Any] = [:]
        
        putDic["appVersion"] = kAppVersion
        putDic["phone"] = DefaultsTool.getValue(.userAccount)
        putDic["uuid"] = DefaultsTool.getValue(.uuid)
        
        networkManager.listenNetworkConfig = { statu in
            putDic["isWifi"] = statu.isWifi
        }
        
        putDic["deviceModel"] = Device.modelName
        putDic["system"] = Device.sysName
        putDic["systemVersion"] = Device.sysVersion
        
        if value.keys.contains(RequestUrl) { /// 包含Host
            putDic["requestUrl"] = value[RequestUrl] ?? "未传入URL"
        }
        
        if value.keys.contains(RequestParams) { /// 包含传参
            putDic["requestParams"] = value[RequestParams] ?? "未传入参数"
        }
        
        if value.keys.contains(Response) { /// 包含返回值
            putDic["response"] = value[Response] ?? "未收到返回值"
        }
        
        if value.keys.contains(ErrorMsg) { /// 包含错误信息
            putDic["errorMsg"] = value[ErrorMsg] ?? "无错误信息"
        }
        
        if value.keys.contains(Header) { /// 包含Header
            putDic["header"] = value[Header] ?? "该接口无Header"
        }
        
        putDic["timeStamp"] = "\(Int(Date().timeIntervalSince1970))"
        
        if #available(iOS 11.0, *) {
            if !putDic.toString(.sortedKeys).isEmpty {
                log.PutContent(key, value: putDic.toString(.sortedKeys))
                self.logGroup.remove()
                self.logGroup.PutLog(log)
                putEnterPostGroup()
            }
        } else {
            if !putDic.toString(.prettyPrinted).isEmpty {
                log.PutContent(key, value: putDic.toString(.prettyPrinted))
                self.logGroup.remove()
                self.logGroup.PutLog(log)
                putEnterPostGroup()
            }
        }
    }
    
    /// 获取到正确的日志EndPoint 重新创建日志对象
    func reloadLogClient() {
        if !self.client.mEndPoint.elementsEqual(DefaultsTool.getValue(.logPoint) ?? "") {
            self.client = LOGClient(endPoint: DefaultsTool.getValue(.logPoint) ?? "", accessKeyID: "", accessKeySecret: "", projectName: "prd-ios-log", token: "", config: SLSConfig(connectType: .wifiOrwwan, cachable: true))
        }
    }
    
    func stopLogTimeClient() {
        self.client.endStopCacheTime()
    }
    
    /// 发送日志方法
    private func putEnterPostGroup() {
        client.PostLog(logGroup, logStoreName: "prd-ios-log") { (_, _) in
        }
    }
}

extension Dictionary {
    /// Dic转String
    /// - Returns: JsonString
    func toString(_ type: JSONSerialization.WritingOptions = []) -> String{
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: type)
            let newStr = String(data: jsonData, encoding: String.Encoding.utf8)
            return newStr ?? ""
        } catch let error as NSError {
            print(error)
            return ""
        }
    }
}

extension Error {
    /// 网络错误日志拼接
    /// - Returns: 网络错误String
    func toString() -> String {
        return ("\((self as NSError).code)" + self.localizedDescription + self.showErrorString())
    }
}

/// 获取日志配置
struct LogService {
    lazy var AliCloudConfig: Action<Void, AliConfigModel> = Action<Void, AliConfigModel>.init { (_) -> Observable<AliConfigModel> in
        RxProvider.instance.rx.requestUUWithAbc(LogApi.LogConfig, parameters: nil).asObservable().mapObjectUUWithAbc(AliConfigModel.self)
    }
}

struct AliConfigModel: HandyJSON {
    var logIosUrl: String = "prd-ios-log.log-global.aliyuncs.com"
    var isLog: Bool = false
}

class LogConfigModule {
    var logService: LogService = LogService()
    let bag = DisposeBag()
    
    /// 日志配置Url/Enable
    let config: PublishSubject<AliConfigModel> = PublishSubject<AliConfigModel>()
    let enable: PublishSubject<Bool> = PublishSubject<Bool>()
    init() {
        logService.AliCloudConfig.elements.map{ model in
            DefaultsTool.setValue(model.logIosUrl, key: .logPoint)
            DefaultsTool.setValue(model.isLog, key: .logEnable)
            let log = AliCloudLog.shared
            log.isEnable = model.isLog
            return model
        }.bind(to: config).disposed(by: bag)
        
        logService.AliCloudConfig.errors.map{_ in
            if let value = DefaultsTool.getValue(.logEnable), value {
                let log = AliCloudLog.shared
                log.isEnable = true
                return true
            } else {
                DefaultsTool.setValue("", key: .logPoint)
                let log = AliCloudLog.shared
                log.isEnable = false
                return false
            }
        }.bind(to: enable).disposed(by: bag)
    }
}

enum LogApi {
    case LogConfig
}


extension LogApi: BaseApi {
    var path: String {
        return "\(SSAPI.logServices)/api/mobile/config"
    }
}

public struct NetWorkStruct {
    var status: NetworkListenerStatus = NetworkListenerStatus.reachable
    var isWifi: Bool = false
    var isReachable: Bool = true
    mutating func updateConfig(reachable: Bool, isWifi: Bool) {
        isReachable = reachable
        self.isWifi = isWifi
        reachable == true ? (status = NetworkListenerStatus.reachable) : (status = NetworkListenerStatus.notReachable)
    }
}

public enum NetworkListenerStatus {
    case notReachable
    case reachable
}

class NetworkListenManager {
    
    /// 实例化
    static let shared = NetworkListenManager()
    
    /// 网络状况别名
    typealias listenStatus = NetWorkStruct
    
    let listener: NetworkReachabilityManager?
    
    /// 闭包回调
    var listenNetworkConfig: ((NetWorkStruct) -> Void)? = { networkConfig in }
    
    /// 获取当前网络状态
    lazy var networkConfig = listenStatus()
    
    /// 网络是否正常
    var isReachable: Bool?
    
    var isWifi: Bool?
    
    init(host: String? = "www.uuabc.com") {
        self.listener = NetworkReachabilityManager(host: "www.uuabc.com")!
        listenNetWork()
    }
    
    private func listenNetWork() {
        self.listener?.listener = { [weak self] status in
            guard let `self` = self else { return }
            if let config = self.listenNetworkConfig {
                switch status {
                case .notReachable,.unknown :
                    self.networkConfig.updateConfig(reachable: false, isWifi: false)
                    self.isReachable = false
                    self.isWifi = false
                    config(self.networkConfig)
                    break
                case .reachable(.ethernetOrWiFi):
                    self.networkConfig.updateConfig(reachable: true, isWifi: true)
                    self.isReachable = true
                    config(self.networkConfig)
                    self.isWifi = true
                    break
                case .reachable(.wwan):
                    self.isWifi = false
                    self.networkConfig.updateConfig(reachable: true, isWifi: false)
                    self.isReachable = true
                    config(self.networkConfig)
                    break
                }
            }
        }
        listener?.startListening()
    }
    
    func reachable() -> Bool {
        return isReachable ?? true
    }
    
    func status() -> NetWorkStruct {
        return networkConfig
    }
    
    func stopListen() {
        self.listener?.stopListening()
    }
}
