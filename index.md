---
layout: main
title: Objective-C
tags: overview
date: 2013-12-28 13:00:00
---
{% capture sdkFullName %}PubNub {{site.data.information.sdk.language}} SDK{% endcapture %}


{% include elements/section-open.ext title=sdkFullName headerSize=1 link="overview" %}
The PubNub Real-Time Network API enables global scable data push applications on Mobile, Tablet and Web clients leveraging the {{sdkFullName}}.  

{% include sdk/information.ext %}
{% include elements/section-close.ext %}
{% include elements/section-open.ext title="Get The Code" headerSize=2 %}
You can access the latest {{sdkFullName}} using one of the following methods:  
{% include sdk/default-get-the-code.ext %}
{% include elements/paragraph-open.ext %}
{% capture markdownContent %}
You also can use {% include elements/link.ext title="CocoaPods" url="http://cocoapods.org" %} to add {{sdkFullName}} SDK into your project and prepare all environment for it by doing next steps:  

* Create an empty Xcode project (if you are starting from the scratch)  
* Create **Podfile** at same level with Xcode project file  
* Add this lines into your **Podfile**: 
{% include code/block-open.ext language="shell" %}pod 'PubNub', '{{site.data.information.sdk.version}}'{% include code/block-close.ext %}
* Run from Terminal: {% include code/block-open.ext language="shell" %}cd path_to_podfile; pod install;{% include code/block-close.ext %}  
* [CocoaPods](http://cocoapods.org "CocoaPods") will pull out latest version and configure all environment in Xcode **workspace** file which you should use for further development.

{% endcapture %}
{{ markdownContent | markdownify | strip_newlines }}{% include elements/paragraph-close.ext %}
{% include elements/section-close.ext %}

{% include elements/section-open.ext title="Import" headerSize=2 %}
{% include elements/paragraph-open.ext %}
{% capture markdownContent %}
For both ways you should add this line into place, where {{sdkFullName}} should be used (you always can add it into `.pch` file so SDK will be available from any part of your application):  
{% include code/block-open.ext %}#import "PNImports.h"{% include code/block-close.ext %}
{% endcapture %}
{{ markdownContent | markdownify | strip_newlines }}{% include elements/paragraph-close.ext %}
{% include elements/section-close.ext %}

{% include elements/section-open.ext title="Dependencies" headerSize=2 %}
{% include elements/paragraph-open.ext %}
{% capture markdownContent %}
You should add next frameworks and libraries to your Xcode project: `CFNetwork.Framework`, `SystemConfiguration.Framework` and `libz.dylib`. If you are targeting Mac OS, then you also should add `CoreWLAN.framework`.
{% endcapture %}
{{ markdownContent | markdownify | strip_newlines }}{% include elements/paragraph-close.ext %}
{% include elements/section-close.ext %}
{% include helper/url-by-tag.ext %}

{{site.baseurl}}/{{ 'main.css' | asset_url }}