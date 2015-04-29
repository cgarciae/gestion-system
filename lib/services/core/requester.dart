part of aristadart.client;

class RequestMaker
{
  Future<dom.HttpRequest> makeRequest (String method, String path, 
                                {dynamic data, Map headers, void onProgress (dom.ProgressEvent p), 
                                String userId, Map<String,dynamic> params})
  {
      
      if (userId != null)
          headers = addOrSet(headers, {Header.authorization : userId});
      
      if (params != null)
          path = appendRequestParams(path, params);
      
      return dom.HttpRequest.request
      (
          path,
          method: method,
          requestHeaders: headers,
          sendData: data,
          onProgress: onProgress
      );
  }
      
  Future<String> requestString (String method, String path, {dynamic data, Map headers, 
                        void onProgress (dom.ProgressEvent p), String userId, 
                        Map<String,dynamic> params}) async
  {
      
      var request = await makeRequest
      (
          method, path, data: data, headers: headers,
          onProgress: onProgress, userId: userId,
          params: params
      );

      return request.responseText;
  }
}

class Requester
{
  final RequestMaker requestMaker;
  
  Requester (this.requestMaker);
  
  Future map (String method, String path, {dynamic data, Map headers, 
                              void onProgress (dom.ProgressEvent p), String userId, Map<String,dynamic> params})
  {
      return requestMaker.requestString
      (
          method, path, data: data, headers: headers,
          onProgress: onProgress, userId: userId,
          params: params
      ) 
      .then (JSON.decode);
  }
  
  Future privateMap (String method, String path, {dynamic data, Map headers, 
                                  void onProgress (dom.ProgressEvent p), Map<String,dynamic> params})
  {
      return map
      (
          method, path, data: data, headers: headers,
          onProgress: onProgress, userId: userId,
          params: params
      );
  }
  
  Future jsonMap (String method, String path, Object obj, {Map headers, 
                                  void onProgress (dom.ProgressEvent p), String userId, Map<String,dynamic> params})
  {
      return map
      (
          method, path, data: encodeJson(obj),
          onProgress: onProgress, userId: userId,
          params: params, headers: addOrSet
          (
              headers,
              {Header.contentType : ContType.applicationJson}
          )
      );
  }
  
  Future privateJsonMap (String method, String path, Object obj, {Map headers, 
                                  void onProgress (dom.ProgressEvent p), Map<String,dynamic> params})
  {
      return jsonMap
      (
          method, path, obj, headers: headers,
          onProgress: onProgress, userId: userId,
          params: params
      );
  }

  Future<dynamic> decoded (Type type, String method, String path, {dynamic data, 
                                  Map headers, void onProgress (dom.ProgressEvent p), 
                                  String userId, Map<String,dynamic> params})
  {
      return requestMaker.requestString
      (
          method, path, data: data, headers: headers, 
          onProgress: onProgress, userId: userId,
          params: params
      )   
      .then (decodeTo (type));
  }
  
  Future<dynamic> private (Type type, String method, String path, {dynamic data, 
                                  Map headers, void onProgress (dom.ProgressEvent p), 
                                  Map<String,dynamic> params})
  {
      return decoded
      (
          type, method, path, data: data, headers: headers, 
          onProgress: onProgress, params: params,
          userId: userId
      );
  }
  


  Future<dynamic> form (Type type, String method, String path, dom.FormElement form, {Map headers, 
                                      void onProgress (dom.ProgressEvent p), String userId,
                                      Map<String,dynamic> params})
  {
      return decoded
      (
          type, method, path, headers: headers,
          onProgress: onProgress, userId: userId,
          params: params, 
          data: new dom.FormData (form)
      );
  }
  
  Future<dynamic> privateForm (Type type, String method, String path, dom.FormElement form, {Map headers, 
                                  void onProgress (dom.ProgressEvent p),
                                  Map<String,dynamic> params})
  {
      return this.form
      (
          type, method, path, form, headers: headers,
          onProgress: onProgress,
          params: params,
          userId: userId
      );
  }
  

/**
 * Hace un request al [path] enviando [obj] codificado a `JSON` y decodifica la respuesta al tipo [type]. 
 * 
 * [method] especifica el verbo http como `GET`, `PUT` o `POST`.
 */
  Future<dynamic> json (Type type, String method, String path, Object obj, 
                                      {Map headers, void onProgress (dom.ProgressEvent p), 
                                      String userId, Map<String,dynamic> params})
  {   
      return decoded
      (
          type, method, path, data: encodeJson(obj),
          onProgress: onProgress, params: params,
          userId: userId, headers: addOrSet
          (
              headers,
              {Header.contentType : ContType.applicationJson}
          )
      );
  }
  

  /**
   * Hace un request al [path] enviando [obj] codificado a `JSON` y decodifica la respuesta al tipo [type]. 
   * 
   * [method] especifica el verbo http como `GET`, `PUT` o `POST`.
   */
  Future<dynamic> privateJson (Type type, String method, String path, Object obj, 
                              {Map headers, void onProgress (dom.ProgressEvent p), 
                              Map<String,dynamic> params})
  {   
      return json
      (
          type, method, path, obj,
          onProgress: onProgress, params: params,
          userId: userId
      );
  }
}