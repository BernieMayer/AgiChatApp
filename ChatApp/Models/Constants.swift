//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

struct Constants {

  struct NotificationKeys {
    static let SignedIn = "onSignInCompleted"
  }


  struct MessageFields {  //Maintains message data
    static var name = "userName"
    static var text = "message"
    static var photoUrl = "photoUrl"
    static var imageUrl = "imageUrl"
    static var timeStamp = "timeStamp"
    static var userId = "userId"

  }
    
    struct  GroupFields { //Maintain Group Field Data
        static var groupId = "groupId"
        static var groupName = "groupName"
        static var lastMessage = "lastMessage"
        static var adminName = "userName"
        static var timeStamp = "timeStamp"
        static var adminId = "userId"
        static var groupIcon = "groupIcon"
        static var userType = "userType"
    }
    
    struct loginFields { //Maintains login field data of current user (logged in user)
        static var name = "firstName"
        static var lastName = "lastname"
        static var email = "email"
        static var phoneNo = "phoneNo"
        static var photoUrl = "photoUrl"
        static var imageUrl = "imageUrl" //stores user's profile pic
        static var userId = "userId"
        static var day = "date"
        static var month = "month"
        static var year = "year"
        static var gender = "gender"
        static var status = "status"
        static var deviceToken = "deviceToken"
    }
    
    struct recentMessageField { //Maintains recent message field data
      
        static var lastMessage = "lastMessage"
        static var recentUserId = "recentUserId"
        static var timeStamp = "timeStamp"
        
    }

    struct statusField { //Maintains Status field data
        
        static var status = "status"
        static var userId = "userId"

    }
    
 }