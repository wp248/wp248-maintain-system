<?php
try {
		$memcached = new Memcached();
    	$memcached->addServer("127.0.0.1", 11211);
		$response = $memcached->get("sample_key");

		if($response==true)
		{
		  echo $response;
		}

		else

		{
		echo "Cache is empty";
		$memcached->set("sample_key", "Sample data from cache") ;
		}
	}
catch (\Throwable $t) {
	echo "caught!\n";

	echo $t->getMessage(), " at ", $t->getFile(), ":", $t->getLine(), "\n";
}


