<?php

if($_GET['url']){
    $url = parse_url($_GET['url']);
}
else
{
    header("HTTP/1.0 404 Not Found");
}

if(isset($url['host'])){

    if($url['host'] == "api.discogs.com")
    {
        header('Content-Type: image/jpeg');
        $cl = curl_init($_GET['url']);
        curl_setopt($cl, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($cl);

        if(curl_getinfo($cl, CURLINFO_HTTP_CODE) == 200)
        {
            echo($output);
        }
        else
        {
            header("HTTP/1.0 404 Not Found");
        }
    }
}