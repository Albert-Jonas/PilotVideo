<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <title>PilotVideo Projekt – README</title>
    <style>
        body {font-family: Arial, sans-serif; line-height: 1.6; margin: 2rem;}
        h1, h2 {color: #2c3e50;}
        table {border-collapse: collapse; width: 100%; margin-bottom: 1rem;}
        th, td {border: 1px solid #ccc; padding: 0.5rem; text-align: left;}
        pre {background: #f8f8f8; padding: 0.75rem; overflow-x: auto;}
        a {color: #2980b9;}
    </style>
</head>
<body>

<h1>PowerShell Projekt – README</h1>

<h2>Felépítés</h2>

<table>
    <thead>
        <tr>
            <th>Fájl/mappa</th>
            <th>Leírás</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><strong>Main.ps1</strong></td>
            <td>A felhasználói felület (UI) – ez a fő szkript, amit a felhasználó futtat.</td>
        </tr>
        <tr>
            <td><strong>Modules/</strong></td>
            <td>Minden modul/komponens ebben a mappában található.</td>
        </tr>
        <tr>
            <td><strong>Test/</strong></td>
            <td>A teszteléshez szükséges szkriptek és fájlok helye.</td>
        </tr>
        <tr>
            <td><strong>TestData/</strong></td>
            <td>A tesztadatként szolgáló mappaszerkezet.</td>
        </tr>
    </tbody>
</table>

<h2>Futtatás</h2>

<h3>1. PowerShell Execution Policy</h3>
<p>A szkriptek futtatásához először engedélyezni kell a script futtatását a helyi gépen. Ez a felhasználóra van bízva.</p>


<pre><code># Minden szkript futtatását engedélyezzük
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
</code></pre>

<h3>2. Projekt futtatása</h3>

<pre><code># Navigáljunk a projekt gyökérkönyvtárába egy powershell terminálban
cd .\Path\To\Project\

# Futtassuk a fő szkriptet
.\Main.ps1
</code></pre>

<h2>Dokumentáció elérhetősége</h2>
<p><a href="https://drive.google.com/drive/folders/1W8QcAfIozylbfN4o66LuhhCqFQTRPWhw?usp=sharing" target="_blank">Google Drive dokumentáció</a></p>

<h2>Tesztelés infó</h2>

<h3>TestData mappa</h3>
<p>A <code>TestData</code> a mappaszerkezetet tartalmazza, amit a tesztek használnak (ő a gyökér könyvtár). A struktúra (mappák, fájlok) a <code>PrepareTestData</code> függvény futtatásával állítható be a szerkesztések dátuma a tesztelt értékre.</p>

<pre><code># Példa: tesztadatok előkészítése
.\Test\PrepareTestData.ps1 -SetupMode Full
</code></pre>

<h3>Komponens tesztjei</h3>
<p>A modulok tesztjei a <code>Test/</code> mappában találhatók. Egy teszt futtatása után a terminálban közvetlenül megjelennek az eredmények.</p>

<pre><code># Példa: egy modul tesztje
.\Test\MyComponent.Tests.ps1
</code></pre>

<h3>Összegzés</h3>
<ul>
    <li><strong>Futtatás:</strong> <code>Set-ExecutionPolicy RemoteSigned</code> → <code>.\Main.ps1</code></li>
    <li><strong>Modulok:</strong> <code>Modules/</code></li>
    <li><strong>Tesztadatok:</strong> <code>TestData/</code> → <code>PrepareTestData.ps1</code></li>
    <li><strong>Teszt futtatás:</strong> <code>.\Test\<em>teszt</em>.ps1</code></li>
</ul>

</body>
</html>