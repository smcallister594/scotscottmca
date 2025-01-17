---
title: Hitting the max application limit in Intune
date: 2022-09-01
last_modified_at: 2022-09-01
tags: [Intune, 3rd Party Apps]
Author: Scott McAllister
---

**Did you know that there is a maximum number of apps you can publish to Intune? Well you do now!**

Hey! This is my first ever blog post, so bear with me!

Earlier this week I was trying to reproduce an issue in my lab and encountered something I'd never seen before in the IntuneManagementExtension.log

When publishing Win32 apps to Intune, I was presented with this error message

{{< highlight powershell >}}
Invoke-RestMethod: {
    "error":{
        "code":"BadRequest","message":"{
            \r\n  \"_version\": 3,\r\n  
            \"Message\": \"New apps may not be created at this time. - 
            Operation ID (for customer support): 00000000-0000-0000-0000-000000000000 - 
            Activity ID: ca6749a9-93ac-454a-a970-5c8a90978635 - 
            Url: https://fef.msub06.manage.microsoft.com/AppLifecycle_2208/StatelessAppMetadataFEService/deviceAppManagement/mobileApps?api-version=5022-07-06\",\r\n  
            \"CustomApiErrorPhrase\": \"\",\r\n  
            \"RetryAfter\": null,\r\n  
            \"ErrorSourceService\": \"\",\r\n  
            \"HttpHeaders\": \"{}\"\r\n
        }",
            "innerError":{"date":"2022-08-30T17:17:03",
            "request-id":"ca6749a9-93ac-454a-a970-5c8a90978635",
            "client-request-id":"ca6749a9-93ac-454a-a970-5c8a90978635"
        }
    }
}
{{< /highlight >}}

{{< highlight xml >}}
<ODataError xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Microsoft.OData.Core">
  <Details i:nil="true"/>
  <ErrorCode>UnsupportedApiVersion</ErrorCode>
  <InnerError i:nil="true"/>
  <InstanceAnnotations/>
  <Message>{ "_version": 3, "Message": "An error has occurred - Operation ID (for customer support): 00000000-0000-0000-0000-000000000000 - Activity ID: 26749895-af71-41be-b823-1291e0cc91ca - Url: https://fef.msub06.manage.microsoft.com/AppLifecycle_2208/StatelessAppMetadataFEService/deviceAppManagement/mobileApps%28%277a006623-ba17-4471-8027-f71722ed1057%27%29?api-version=5022-07-06%5C%22,%5Cr%5Cn", "CustomApiErrorPhrase": "", "RetryAfter": null, "ErrorSourceService": "", "HttpHeaders": "{}" }</Message>
  <Target i:nil="true"/>
</ODataError>
{{< /highlight >}}

I had figured that I had just hit a maximum app limit and almost just left it alone, but I curious about what that limit was I hit up the Graph API  to get the total number of published apps

{{< highlight powershell >}}
$mobileAppsResults = Invoke-RestMethod -uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Method Get -Headers $Headers

($mobileAppsResults).count
500
{{< /highlight >}}

This returned a total of 500 applications which seemed like a very low number, so I wondered if it affected all application types or if it was just a Win32 app limit I had reached. To test this, I tried to manually create some different app types manually in the Endpoint UI. 

I received the same error when trying to create an MSfB app and an iOS Store app
{{< image src="/images/2022-09-01/MSfB_iOS.jpg" caption="MSfB iOS (`image`)" >}}

So I asked around some others and @IntuneSuppTeam on Twitter and received this response
{{< image src="/images/2022-09-01/Twitter_Response.png" caption="Twitter Response (`image`)" >}}

Intrigued further, I purchased an F1 licence and assigned it to my demo tenant and that 500 app limit was lifted immediately. 

Curious what that upper limit was, [Jake Shack](https://twitter.com/shackelfjaco) threw together a quick script to mass publish empty applications to Intune

{{< highlight powershell >}}
$Version = 1
$Job_Nb = 1..500
$Job_Xy = 1..10

foreach ($Xy in $Job_Xy) {
    #code that creates apps
    Foreach ($Nb in $Job_Nb) {
        

        Start-Job -Name $Nb -ScriptBlock {
            $Increment_job = $args[0]
            $MSToken = Get-MsalToken -ClientId "xxxxxx" -ClientSecret (ConvertTo-SecureString "xxxxxx" -AsPlainText -Force) -TenantId "xxxxxx.onmicrosoft.com"
            $AuthToken = $MSToken.AccessToken
            $Headers = @{
                "Content-Type"  = "application/json"
                "Authorization" = "Bearer $($AuthToken)"
            }
        
        
            $Method = "POST"
            $URI = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/"
            $Test = Get-Content -Raw -Path ".\DummyApps.json" | convertfrom-Json
            $DisplayName = "FakeApp#"
            $NewName = $DisplayName + $Increment_job
            $Test.displayName = $NewName
            $Test = $Test | Convertto-json
        
        
        
            Invoke-RestMethod -uri $Uri -Method $Method -body $Test -Headers $Headers
      
        } -ArgumentList $Version

        $Version++
    }

    Wait-Job -Name $job_nb | Receive-Job
    Start-Sleep -seconds 60
}
{{< /highlight >}}

This script, coupled with a [JSON file](https://github.com/smcallister594/scotscottmca/blob/main/assets/files/DummyApps.json) containing the app information, let me quickly publish as many apps as Graph would let me before being rate limited

Over the course of that afternoon I let this script run it's course until I hit the same error message again, 

{{< highlight powershell >}}
Invoke-RestMethod: {
    "error":{
        "code":"BadRequest","message":"{
            \r\n  \"_version\": 3,\r\n  
            \"Message\": \"New apps may not be created at this time. - 
            Operation ID (for customer support): 00000000-0000-0000-0000-000000000000 - 
            Activity ID: ca6749a9-93ac-454a-a970-5c8a90978635 - 
            Url: https://fef.msub06.manage.microsoft.com/AppLifecycle_2208/StatelessAppMetadataFEService/deviceAppManagement/mobileApps?api-version=5022-07-06\",\r\n  
            \"CustomApiErrorPhrase\": \"\",\r\n  
            \"RetryAfter\": null,\r\n  
            \"ErrorSourceService\": \"\",\r\n  
            \"HttpHeaders\": \"{}\"\r\n
        }",
        "innerError":{
            "date":"2022-08-30T17:17:03",
            "request-id":"ca6749a9-93ac-454a-a970-5c8a90978635",
            "client-request-id":"ca6749a9-93ac-454a-a970-5c8a90978635"
        }
    }
}
{{< /highlight >}}

Checking what limit I had hit this time, I reran the previous query to get a count and this time I was given a count of exactly 10000 apps. 

Again curious if that was just Win32 apps, I attempted to manually create another MSfB and iOS app but was met with the same error in the UI
{{< image src="/images/2022-09-01/MSfB_iOS.jpg" caption="MSfB iOS (`image`)" >}}

I received an update from @IntuneSuppTeam on this 
{{< image src="/images/2022-09-01/Twitter_response_2.png" caption="Twitter response (`image`)" >}}

However as previously mentioned, at the 10k app limit I am unable to publish any more applications regardless of the type!

At the time of writing this, I have yet to receive and further response on this but if I do I'll be sure to update this post :)

Thanks for reading!