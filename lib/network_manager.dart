import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:rxdart/rxdart.dart';

class NetworkManager{
  static BaseOptions options = BaseOptions(
      // baseUrl:BaseUrl.BASE_URL,
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 100000),
      headers: {
        "content-type" :"application/json;charset=UTF-8",
      }
  );
  Dio client = Dio(options);

  Future<SharedApiResponse> networkRequestManager(RequestType rxRequestType,String requestUrl, {dynamic body, queryParameters,
    bool useAuth = true, BehaviorSubject<int>? progressStream,}) async{

    SharedApiResponse apiResponse;
    var baseUrl =  'BaseUrl.BASE_URL';
    String url = '$baseUrl$requestUrl';
    client.interceptors.add(RequestsInspectorInterceptor());
    if(useAuth){
      String token = 'await SharedPref.getToken()';
      client.options.headers["Authorization"]  = "Bearer $token";
      debugPrint("Header: ${ client.options.headers} Bearer: $token', Url: $url, Body: $body, Query: $queryParameters");
    }else{
      debugPrint("Header: ${ client.options.headers} Bearer: n/a, Url: $url, Body: $body, Query: $queryParameters");
    }

    try{
      switch(rxRequestType){
        case RequestType.GET:
          var response = await client
              .get(url,queryParameters: queryParameters,);
          debugPrint("get: ${response.data.toString()}");
          apiResponse = SharedApiResponse.fromJson(response);
          break;
        case RequestType.POST:
          var response = await client
              .post(url,data: body,queryParameters: queryParameters, onSendProgress:(int count, int total){
            if(progressStream!=null){
              double percentage  = (count/total) * 100 ;
              progressStream.sink.add(percentage.toInt());
            }
          });
          debugPrint("post: ${response.data.toString()}");
          if(response.statusCode==204){
            apiResponse = SharedApiResponse("Success",{"status": "Success"},true);
          }else{
            apiResponse = SharedApiResponse.fromJson(response);
          }
          break;
        case RequestType.PUT:
          var response = await client
              .put(url,data: body,queryParameters: queryParameters);
          debugPrint("put: ${response.data.toString()}");
          apiResponse = SharedApiResponse.fromJson(response);
          break;
        case RequestType.PATCH:
          var response = await client
              .patch(url,data: body,queryParameters: queryParameters);
          debugPrint("put: ${response.data.toString()}");
          apiResponse = SharedApiResponse.fromJson(response);
          break;
        case RequestType.DELETE:
          var response = await client
              .delete(url,data: body,queryParameters: queryParameters);
          debugPrint("delete: ${response.data.toString()}");
          apiResponse = SharedApiResponse.fromJson(response);
          break;
        default:
          var response = await client
              .post(url,data: body,queryParameters: queryParameters);
          debugPrint("post: ${response.data.toString()}");
          apiResponse = SharedApiResponse.fromJson(response);
          break;
      }
      return apiResponse;

    }on TimeoutException catch(n) {
      debugPrint("Network Timeout Error response: $n");
      throw ("Network timed out, please check your network connection and try again");
    }  on DioException catch(e){
      debugPrint("Internal Error response: ${e.error}");

      if (DioExceptionType.receiveTimeout == e.type || DioExceptionType.connectionTimeout == e.type) {
        debugPrint("Network Timeout Error response: $e");
        throw ("Network timed out, please check your network connection and try again");
      } else if (DioExceptionType.unknown == e.type) {
        throw ("Internet connection error, please check your network connection and try again");
      }
      if(e.response==null){
        if(e.error.toString().contains("XMLHttpRequest")){
          throw ("Internet connection error, please check your network connection and try again");
        }
        throw ("Unable to process this request at this time");
      }
      if (e.response?.statusCode == 503 || e.response?.statusCode == 502 || e.response?.statusCode == 501) {
        throw ("Internal Server Error, Please try again later");
      } else if (e.response?.statusCode == 401) {
        apiResponse = SharedApiResponse.fromJson(e.response);
        throw(apiResponse.message);
      }else if (e.response?.statusCode == 404) {
        throw ("Resource not found, please try again later");
      }else if (e.response?.statusCode?.isBetween(399,499)==true) {
        apiResponse = SharedApiResponse.fromJson(e.response);
        debugPrint("Server ${e.response?.statusCode} response: ${apiResponse.message}");
        throw (apiResponse.message);
      } else if (e.response?.statusCode?.isBetween(500,599)==true)  {
        apiResponse = SharedApiResponse.fromJson(e.response);
        debugPrint("Server 500 response: $apiResponse");
        throw ("We are unable to process request at this time, please try again later \n[${e.response?.statusCode}]");
      } else {
        debugPrint("Network Unknown response: ${e.response}");
        apiResponse = SharedApiResponse.fromJson(e.response);
        throw (apiResponse.message);
      }
    }
    catch(e){
      debugPrint("Internal error response $e");
      throw ("An internal error occurred while processing this request");
    }

  }

}

extension Range on num {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }
}

enum RequestType {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

class SharedApiResponse<T>{
  late String message;
  late T data;
  late bool success=true;

  SharedApiResponse(this.message, this.data, this.success);

  SharedApiResponse.fromJson(Response<dynamic>? parsedJson) {
    message = parsedJson?.data?['message'] ?? "An error occurred while processing this request";
    data = parsedJson?.data?['data'];
    success = data!=null || parsedJson?.statusCode == 200;
  }

  Map toJson() {
    Map map = {};
    map["message"] = message;
    map["data"] = data;
    return map;
  }

}