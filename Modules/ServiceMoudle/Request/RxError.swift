//
//  RxError.swift
//  UUStudent
//
//  Created by Asun on 2020/7/20.
//  Copyright © 2020 UUabc. All rights reserved.
//

import UIKit

public enum EmptyDataType:Int {
    case TimeOut = -100// 超时
    case Network = -200// 网络出错
    case NoData = -300// 没有数据
    case Service = -400// 服务器接口出错
    case NotLogin = -500 // 没有登录
    case Success = 0 //请求成功
}

public enum RxError: Error {
    case networkError(Error)
    case analyticalModel(_ type: EmptyDataType)
    case resultNoData(_ type: EmptyDataType)
    case serverError(_ type: EmptyDataType)
    
    func description() -> String {
        switch self {
        case .networkError:
            return "网络错误"
        case .analyticalModel:
            return "Json解析失败"
        case .serverError:
            return "服务器错误"
        case .resultNoData:
            return "请求空数据"
        }
    }
    
    /// 解析返回类型
    /// - Returns: 返回的空数据类型
    func descriptionEmptyData() -> EmptyDataType {
        switch self {
        case .networkError(let error):
            let er = (error as NSError)
            switch er.code {
            case NSURLErrorTimedOut: /// -1001（请求超时）
                return EmptyDataType.TimeOut
            case NSURLErrorBadURL: /// -1000（请求的URL错误，无法启动请求）
                return EmptyDataType.Network
            case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
                return EmptyDataType.Network
            case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
                return EmptyDataType.Network
            case NSURLErrorCannotConnectToHost: ///-1004（连接host失败）
                return EmptyDataType.Network
            case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
                return EmptyDataType.Network
            case NSURLErrorNotConnectedToInternet: ///-1009（断网状态）
                return EmptyDataType.Network
            default:
                return EmptyDataType.Network
            }
        case .analyticalModel, .serverError:
            return EmptyDataType.Service
        case .resultNoData(let type):
            return type
        }
    }
}

extension Error {
    func showErrorString() -> String {
        var errorMesg: String = ""
        switch (self as NSError).code {
        case -1://NSURLErrorUnknown
            errorMesg = "无效的URL地址"
            break
        case -999://NSURLErrorCancelled
            errorMesg = "无效的网络地址"
            break
        case -1000://NSURLErrorBadURL
            errorMesg = "无效的网络地址"
            break
        case -1001://NSURLErrorTimedOut
            errorMesg = "网络不给力，请稍后再试"
            break
        case -1002://NSURLErrorUnsupportedURL
            errorMesg = "不支持的网络地址"
            break
        case -1003://NSURLErrorCannotFindHost
            errorMesg = "找不到服务器"
            break
        case -1004://NSURLErrorCannotConnectToHost
            errorMesg = "连接不上服务器"
            break
        case -1103://NSURLErrorDataLengthExceedsMaximum
            errorMesg = "请求数据长度超出最大限度"
            break
        case -1005://NSURLErrorNetworkConnectionLost
            errorMesg = "网络连接异常"
            break
        case -1006://NSURLErrorDNSLookupFailed
            errorMesg = "DNS查询失败"
            break
        case -1007://NSURLErrorHTTPTooManyRedirects
            errorMesg = "HTTP请求重定向"
            break
        case -1008://NSURLErrorResourceUnavailable
            errorMesg = "资源不可用"
            break
        case -1009://NSURLErrorNotConnectedToInternet
            errorMesg = "无网络，请检查网络连接"
            break
        case -1010://NSURLErrorRedirectToNonExistentLocation
            errorMesg = "重定向到不存在的位置"
            break
        case -1011://NSURLErrorBadServerResponse
            errorMesg = "服务器响应异常"
            break
        case -1012://NSURLErrorUserCancelledAuthenticatio
            errorMesg = "用户取消授权"
            break
        case -1013://NSURLErrorUserAuthenticationRequired
            errorMesg = "需要用户授权"
            break
        case -1014://NSURLErrorZeroByteResource
            errorMesg = "零字节资源"
            break
        case -1015://NSURLErrorCannotDecodeRawData
            errorMesg = "无法解码原始数据"
            break
        case -1016://NSURLErrorCannotDecodeContentData
            errorMesg = "无法解码内容数据"
            break
        case -1017://NSURLErrorCannotParseResponse
            errorMesg = "无法解析响应"
            break
        case -1018://NSURLErrorInternationalRoamingOff
            errorMesg = "国际漫游关闭"
            break
        case -1019://NSURLErrorCallIsActive
            errorMesg = "被叫激活"
            break
        case -1020://NSURLErrorDataNotAllowed
            errorMesg = "数据不被允许"
            break
        case -1021://NSURLErrorRequestBodyStreamExhauste
            errorMesg = "请求体"
            break
        case -1100://NSURLErrorFileDoesNotExist
            errorMesg = "文件不存在"
            break
        case -1101://NSURLErrorFileIsDirector
            errorMesg = "文件是个目录"
            break
        case -1102://NSURLErrorNoPermissionsToReadFile
            errorMesg = "无读取文件权限"
            break
        case -1200://NSURLErrorSecureConnectionFailed
            errorMesg = "安全连接失败"
            break
        case -1201://NSURLErrorServerCertificateHasBadDat
            errorMesg = "服务器证书失效"
            break
        case -1202://NSURLErrorServerCertificateUntrusted
            errorMesg = "不被信任的服务器证书"
            break
        case -1203://NSURLErrorServerCertificateHasUnknownRoot
            errorMesg = "未知Root的服务器证书"
            break
        case -1204://NSURLErrorServerCertificateNotYetValid
            errorMesg = "服务器证书未生效"
            break
        case -1205://NSURLErrorClientCertificateRejected
            errorMesg = "客户端证书被拒"
            break
        case -1206://NSURLErrorClientCertificateRequired
            errorMesg = "需要客户端证书"
            break
        case -2000://NSURLErrorCannotLoadFromNetwork
            errorMesg = "无法从网络获取"
            break
        case -3000://NSURLErrorCannotCreateFile
            errorMesg = "无法创建文件"
            break
        case -3001://  NSURLErrorCannotOpenFile
            errorMesg = "无法打开文件"
            break
        case -3002://NSURLErrorCannotCloseFile
            errorMesg = "无法关闭文件"
            break
        case -3003://NSURLErrorCannotWriteToFile
            errorMesg = "无法写入文件"
            break
        case -3004://NSURLErrorCannotRemoveFile
            errorMesg = "无法删除文件"
            break
        case -3005://NSURLErrorCannotMoveFile
            errorMesg = "无法移动文件"
            break
        case -3006://NSURLErrorDownloadDecodingFailedMidStream
            errorMesg = "下载解码数据失败"
            break
        case -3007://NSURLErrorDownloadDecodingFailedToComplete
            errorMesg = "下载解码数据失败"
            break
        default: break
        }
        return errorMesg
    }
    
    /// 解析返回类型
    /// - Returns: 返回的空数据类型
    func descriptionEmptyData() -> EmptyDataType {
        let er = (self as NSError)
        switch er.code {
        case NSURLErrorTimedOut: /// -1001（请求超时）
            return EmptyDataType.TimeOut
        case NSURLErrorBadURL: /// -1000（请求的URL错误，无法启动请求）
            return EmptyDataType.Network
        case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
            return EmptyDataType.Network
        case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
            return EmptyDataType.Network
        case NSURLErrorCannotConnectToHost: ///-1004（连接host失败）
            return EmptyDataType.Network
        case NSURLErrorCannotFindHost: ///-1003（URL的host名称无法解析，即DNS有问题）
            return EmptyDataType.Network
        case NSURLErrorNotConnectedToInternet: ///-1009（断网状态）
            return EmptyDataType.Network
        default:
            return EmptyDataType.Network
        }
    }
}


