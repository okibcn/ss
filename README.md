# SS (Scoop **Super Search**) 

<br/>

Scoop Super Search, instantaneous results, UTF-8 and regex compatible. The fastest search engine for Scoop.

<br/>
<img width="1107" alt="image" src="https://user-images.githubusercontent.com/22417711/217578903-bfd17b11-9be4-41af-9f7f-6bd45a1a2aac.png">

____

## **FEATURES**

<br/>

### - 🛸 **'Outta This World' speed**

<br/>

**Scoop Super Search** is capable of searching in more than 800 buckets and 52,000 app manifests in internet. It uses the lightning fast ScoopMaster database to provide intantaneous results in less than 500 ms.

<br/>


### - 🔍 **Searches in names AND descriptions improving the search flexibility.**
<br/>
Most Scoop search systems such as [Scoop.sh](http://scoop.sh) or [Scoop-Directory](https://rasa.github.io/scoop-directory/search) provide results only referred to the app name. SS can search also in the app descriptions.

<br/>


### - 🔍&🔍 **Match All keywords capability.** 
<br/>
Most Scoop search systems provide results for a single keyword. SS can search combinations of OR and AND.

<br/>


### - 🔧 **Complex REGEX search patterns for advanced users**
<br/>

**SS** is also cabable of extended **REGEX** pattern seaches, accepting even multiple regex patterns.

<br/>


### - **(音乐) UTF-8 compatible**
<br/>

**SS** accepts searches in UTF-8 encoding, supporting searches in descriptions when the language uses suplemental Unicode pages. Please note that this feature requires a UTF-8 capable terminal such as Windows Terminal.

<br/>


### - 📝 **Last-manifest filter**
<br/>

Typical search utilities provide only the list of matches including all the versions and all the manifests for that app. **SS** can also filter out all the noise in the report, displaying only the latests manifest of the highest version of each app.

<br/>


### - 📝 **Interoperability with other PowerShell scripts**
<br/>

**SS** can provide the output as a PSObject format so other PowerShell utilities could use the data for other tasks.

<br/>

____

<br/>

## **INSTALLATION**
<br/>

This app is a CLI utility for the Scoop framework and requires [Scoop ackage Manager](http://scoop.sh) as a pre-requisite.

From there the installation is straightforward.

1. Add the definitive Scoop Master meta-bucket with all the scoop apps:
```pwsh
scoop bucket add .sm http://github.com/okibcn/ScoopMaster
```
2. Install **SS**:
```pwsh
scoop install ss
```

App update:
```pwsh
scoop update ss
```

App uninstall:
```pwsh
scoop uninstall ss
```

<br/>

____

<br/>

## **USAGE**

<br/>

Usage: ss [OPTIONS] [Patterns]

 **SS** searches in all the known buckets at a lighning speed. It not only searches in the name field, but also in the desscription. Regex and UTF-8 compatible.
```
 Options:

  no opt. searches for all the matches in the name and description fields.
     -n   Searches only in the name field.
     -s   Simple search. searches an exact name match (implies -n).
     -e   Full expanded regex search.
     -l   Search latest versions only
     -r   raw, no color and no header. Outputs data as a PowerShell object.
     -h   Prints this help
```

<br/>

____

<br/>

## **EXAMPLES**

<br/>

- Search for all the packages with both words in the name or description:
```pwsh
ss scoop search
```
- Search for an app in which the name contains both 'nvidia' AND 'driver'
```pwsh
ss -n nvidia driver 
```
- Simple search for the **ss** app
```pwsh
ss -s ss 
```
- Returns apps containing 'tool' and, 'nvidia' or 'radeon'
```pwsh
ss -n "nvidia|radeon" tool
```
- Get the latest manifests of scoop search utilities
```pwsh
ss -l search scoop 
```
- latests versions of apps ending in 'ss' starting with 's'
```pwsh
ss -n -l -e ss$ ^s 
```
- UTF-8 search of all the apps containing the word 音乐 (music) in the description.
```pwsh
ss -l 音乐 
```
- stores in the `$apps` variable a PSObject with all the Scoop manifests — more than 52,000.
```pwsh
$apps = ss -r .* 
```
