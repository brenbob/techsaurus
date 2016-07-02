<?php 

// SQL credentials 
include 'sql_credentials.php';
        
//Connecting to your database
$connect = mysqli_connect($hostname, $username, $password, $dbname); 

// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//query: 
 if ($_REQUEST["tag"] == "all") {
	// get all tags and categories

	$query = "select tag, title IS NOT NULL as isCat from (SELECT distinct SUBSTRING_INDEX(SUBSTRING_INDEX(terms.tags, ', ', numbers.n), ', ', -1) tag FROM (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) numbers INNER JOIN terms ON CHAR_LENGTH(terms.tags) - CHAR_LENGTH(REPLACE(terms.tags, ', ', ''))>=numbers.n-1) as tags LEFT OUTER JOIN categories on tag = title union select title as tag,1 as isCat from categories order by tag;" or die("Error in the query.." . mysqli_error($connect)); 

	//execute the query. 
	$result = $connect->query($query); 
	getTags($result);

} else if (!empty($_REQUEST["tag"])) {
	// get all terms for requested tag in alpha order
	$query = "SELECT t.*, r.title as resource, r.url FROM terms as t LEFT OUTER JOIN resources as r on t.title like r.tags  where t.tags like '%" . $_REQUEST["tag"] . "%' order by t.title;" or die("Error in the query.." . mysqli_error($connect)); 
	//execute the query. 
	$result = $connect->query($query); 
	getTerms($result);

} else if (!empty($_REQUEST["cat"])) {
	// get top-level categories in alpha order
	$query = "SELECT * FROM categories ORDER BY title;" or die("Error in the query.." . mysqli_error($connect)); 
	//execute the query. 
	$result = $connect->query($query); 
	getList($result);
	
	
} else {
	// get all terms in alpha order
	$query = "SELECT t.*, r.title as resource, r.url FROM terms as t LEFT OUTER JOIN resources as r on t.title like r.tags order by t.title;" or die("Error in the query.." . mysqli_error($connect)); 
	//execute the query. 
	$result = $connect->query($query); 
	getTerms($result);
}

//echo $query;

// todo
// escape double quotes


function getTerms($result)
{

	header('Content-Type: application/json');
	header('Access-Control-Allow-Origin: *');

	echo "{ \"Terms\":[ \n"; 

	$i = 1; 
	$num_rows = mysqli_num_rows( $result );
	$prev_term = "";

	// node values are obtained before resource values, but 
	$strNodeEnd = "";
	$strResources = "";

	while($row = mysqli_fetch_array($result)) { 
	  if ($prev_term != $row["title"]) {
	  		// emit resources and end-of-node string for previous term
	  	if (!empty($strResources)) {
	  		// remove comma from last resource
	  	  echo rtrim($strResources, ",\n") . "\n]";
	  	}
	  	echo $strNodeEnd;
	  	$strResources = "";

		  echo "{\"title\":\"" . $row["title"] . "\",\n"; 
		  echo "\"description\":\"" . $row["description"] . "\",\n"; 
		  echo "\"tags\":\"" . str_replace(', ',',', $row["tags"]) . "\",\n"; 
		//  echo "\"synonyms\":\"" . $row["synonyms"] . "\",\n"; 
		  echo "\"updated\":\"" . $row["updated"] . "\""; 

	  // last  item should not have a trailing comma

		  if ($i < $num_rows) {
			  $strNodeEnd = "\n},\n";
			} else {
			  $strNodeEnd = "}\n";		
			}
	  } 
		if ($row["resource"]) {
	  		if ($prev_term != $row["title"]) {
				$strResources = ",\n  \"resources\":[\n"; 
		  	}
			  $strResources = $strResources . "{ \"title\":\"" . $row["resource"] . "\", \"link\":\"" . $row["url"] . "\"},\n"; 
		}
		$prev_term = $row["title"];
		$i++;
	} 
	// emit last node and closing brackets
		if (!empty($strResources)) {
	  		// remove comma from last resource
	  	  $strResources = rtrim($strResources, ",\n") . "\n]";
		  $strNodeEnd = "}\n";		
	  	}

	echo $strResources . $strNodeEnd;
	echo "]}"; 

}

// output single-column data sets
function getList($result)
{

	header('Content-Type: application/json');
	header('Access-Control-Allow-Origin: *');
	echo "{ \"Categories\":[ "; 

	$i = 1; 
	$num_rows = mysqli_num_rows( $result );
	$prev_term;

	// node values are obtained before resource values, but 
	$strNodeEnd = "";

	while($row = mysqli_fetch_array($result)) { 
	  if ($prev_term != $row["title"]) {
	  	echo $strNodeEnd;

		  echo "\"" . $row["title"] . "\""; 

	  // last  item should not have a trailing comma
		  if ($i < $num_rows) {
			  $strNodeEnd = ",";
			} else {
			  $strNodeEnd = "";		
			}
	  } 
		$prev_term = $row["title"];
		$i++;
	} 
	// emit last node and closing brackets
	echo $strNodeEnd;
	echo "]}"; 

}

function getTags($result)
{

	header('Content-Type: application/json');
	header('Access-Control-Allow-Origin: *');
	echo "{ \"Tags\":[\n"; 

	$i = 1; 
	$num_rows = mysqli_num_rows( $result );
	$prev_term = "";

	// node values are obtained before resource values, but 
	$strNodeEnd = "";

	while($row = mysqli_fetch_array($result)) { 
	  if ($prev_term != $row["tag"]) {

	  	echo $strNodeEnd;

		  echo "{\"title\":\"" . $row["tag"] . "\",\n"; 
		  echo "\"isCat\":" . $row["isCat"] . "\n"; 

	  // last  item should not have a trailing comma
		  if ($i < $num_rows) {
			  $strNodeEnd = "\n},\n";
			} else {
			  $strNodeEnd = "}\n";		
			}
	  } 
		$prev_term = $row["tag"];
		$i++;
	} 
	// emit last node and closing brackets
	echo $strNodeEnd;
	echo "]}"; 

}


?> 
