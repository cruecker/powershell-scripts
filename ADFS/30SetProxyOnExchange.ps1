#Proxy für den Exchange setzten
$proxy = "http://<ip:port>"
get-exchangeserver | Set-ExchangeServer -InternetWebProxy $proxy
