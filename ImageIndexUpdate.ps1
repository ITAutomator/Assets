$scriptFullname = $PSCommandPath ; if (!($scriptFullname)) {$scriptFullname =$MyInvocation.InvocationName }
$scriptDir      = Split-Path -Path $scriptFullname -Parent

# Define the folder path containing subfolders with images
$folderPath = $scriptDir

################
Add-Type -AssemblyName System.Drawing

Write-Host "Getting .png files in: $($folderPath)"
# Define the output path for the index.html
$outputFile = Join-Path $folderPath "index.html"

# Start building the HTML content
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Image Thumbnails</title>
    <style>
        table {
            width: 500px;
            border-collapse: collapse;
        }
        td {
            padding: 10px;
            text-align: center;
        }
        img {
            max-width: 150px;
            height: auto;
        }
        body {
            font-family: sans-serif;
        }
        .file-path {
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <h1>Image Thumbnails</h1>
    <table>
"@

# Collect all PNG images in the folder and its subfolders
$imageFiles = Get-ChildItem -Path $folderPath -Recurse -Filter "*.png"

# Initialize a counter for columns
$columnCounter = 0

# Start the first table row
$htmlContent += "        <tr>`r`n"
$i = 0
foreach ($image in $imageFiles) {
    $i += 1
    # Get the relative path of the image
    $relativePath = $image.FullName.Replace($folderPath, "").TrimStart("\\")

    # Get the image dimensions
    try {
        Write-Host "$($i): $($relativePath) " -NoNewline
        $dimensions = [System.Drawing.Image]::FromFile($image.FullName)
        $resolution = "$($dimensions.Width) x $($dimensions.Height)"
        $dimensions.Dispose()
    } catch {
        $resolution = "Unknown"
    }
    Write-Host $resolution

    # Add a table cell with the image thumbnail, clickable link, file path, and resolution
    $htmlContent += @"
            <td>
                <a href='$relativePath'><img src='$relativePath' alt='Thumbnail'></a><br>
                <a href='$relativePath' class='file-path'>$relativePath</a><br>
                <span class='file-path'>$resolution</span>
            </td>
"@

    # Increment the column counter
    $columnCounter++

    # Check if 3 columns are filled
    if ($columnCounter -eq 3) {
        # Close the current row and start a new one
        $htmlContent += "        </tr>`r`n        <tr>`r`n"
        $columnCounter = 0
    }
}

# Close any remaining open row
if ($columnCounter -ne 0) {
    $htmlContent += "        </tr>`r`n"
}

# Close the table and HTML tags
$htmlContent += @"
    </table>
</body>
</html>
"@

# Write the HTML content to the output file
Set-Content -Path $outputFile -Value $htmlContent

Write-Output "Index.html generated at $outputFile"
################

Start-Sleep 3