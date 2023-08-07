---
title: Sending your users messages the cool way?
date: 2023-08-07
last_modified_at: 2023-08-07
tags: [Intune, Organizational Messages, Notifications, Endpoint, Windows 11]
Author: Scott McAllister
Draft: true
---

## What are Organizational messages? 

Well, they're a pretty cool feature that let's you get information out to targetted users easier by displaying branded content in visible areas of the desktop.

Currently, There are 3 areas you can display messages; The Taskbar, The Notification area and the Getting Started App. 

## Prerequisites
Before we dive into the 3 areas, you will need to check a few prerequisites to ensure you can make use of Organizational messages.

### Licencing
The licence types that allow the use of Organizational messages are:
- Microsoft 365 E3
- Microsoft 365 E5
- Windows 10/11 Enterprise E3 with Intune Plan 1
- Windows 10/11 Enterprise E5 with Intune Plan 1.

### Organizational messages delivery policy
There are certain experience and Windows Spotlight policies in Microsoft Intune that block the delivery of organizational messages. You will want to review the Microsoft documentation on enabling the relevant policies - [Policy documentation](https://learn.microsoft.com/en-gb/mem/intune/remote-actions/organizational-messages-prerequisites#policy-requirements)

### Microsoft messages
You get to decide whether or not to allow Microsoft messages to be shown - [Microsoft messaging policy](https://learn.microsoft.com/en-gb/mem/intune/remote-actions/organizational-messages-prerequisites#policy-requirements)

### OS version
Organizational messages are supported on devices running Windows 11, version 22H2 or later.

### Branding
You'll need three sizes of logo, in PNG format with transparent backgrounds:
- 48 x 48 pixels used for messages in the Notifications area
- 64 x 64 pixel images used for messages attached to the Taskbar
- 50 x 50-100 pixels used for Get Started app messages

## Lets look at the areas

### The Taskbar & Notificaiton area
We'll look at these 2 areas together, as they're almost identical for configuration. 

![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/Taskbar.png?raw=true)
![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/NotificationArea.png?raw=true)

![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/Taskbar_1.png?raw=true)
![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/NotificationArea_1.png?raw=true)

#### Themes
When creating your Taskbar or Notification area message you can choose a theme, each theme has a slightly different look & feel for displaying different information.
- Taskbar
    - Mandatory update
    - Security update
    - Important action
    - Important information
    - Key meeting
    - Latest video
    - Leadership updates
    - Team updates
    - Planned outage
- Notification area
    - Organizational HR training
    - Organizational skills training
    - Organizational training
    - Organizational update
    - Update browser
    - Update device

#### Scheduling
Scheduling the notifications is fairly simple, with only 3 options. 

{{< admonition type=tip title="Note" open=true >}}
Messages may start delivering up to 24 hours after scheduling.
{{< /admonition >}}

| Option | Description |
|:------:| -----------|
| First day to show message | You need to finish creating your message at least 1 day before this date. |
| Last day to show message | Last day to show message (must be at least 7 days after start date) |
| Message repeat frequency | The message appears for the entire time until the user takes the recommended action.<br/> If they dismiss the message, it will reappear according to the frequency you select. |

### The Getting Started App

The Getting Started app is slightly different to the Taskbar and Notification areas because it is only ever shown the first time a user runs it after their device is enrolled in Intune. It's really useful for welcoming new users to your organizations, as you can send them information on getting started, useful apps, policies and tips. They are also links to help them personalize their device and setting up their profile.  

{{< admonition type=tip title="Note" open=true >}}
The app automatically opens during the first seven days after a device is enrolled. Message stay visible for 30 days.
{{< /admonition >}}

![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/GetStartedApp.png?raw=true)
![image](https://github.com/smcallister594/scotscottmca/blob/main/assets/images/Organizationalmessages/GetStartedApp_1.png?raw=true)

#### Messages
You're able to add 2 messages to the Getting Started App, each of which will require a URL to redirect to.
- First Message
    - Review benefits
    - Review organization
    - Get started with device
- Second message
    - Organizational training
    - Organization policies
    - Help resources
    - Update VPN
