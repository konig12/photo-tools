<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	
	<title>TITLETEXT</title>
	
	<link rel="stylesheet" type="text/css" href="/Pictures/.style.css" />
	<link rel="stylesheet" type="text/css" href="/Pictures/.resources/fancy.css" />
	
	<script type="text/javascript" src="/Pictures/.js/jquery-1.2.3.pack.js"></script>
	<script type="text/javascript" src="/Pictures/.js/jquery.fancybox-1.0.0.js"></script>
	
	<script type="text/javascript">
	
		$(function(){
		
			$(".photo-link").fancybox({ 'zoomSpeedIn': 500, 'zoomSpeedOut': 500, 'overlayShow': true }); 
		
		});
	
	</script>
</head>

<body>

	<div id="page-wrap">
	
	<h1>TITLETEXT</h1>
	<?php
		
		/* settings */
		$image_dir = './';
		$per_column = 6;
		
		
		/* step one:  read directory, make array of files */
		if ($handle = opendir($image_dir)) {
			while (false !== ($file = readdir($handle))) 
			{
				if ($file != '.') 
				{
					if(strstr($file,'.thm') && !strstr($file,':PR:'))
					{
						$files[] = $file;
					} else if (strstr($file,'.avi') || strstr($file,'.AVI') || strstr($file,'.mpg') || strstr($file,'.MPG') || strstr($file,'.MOV') || strstr($file,'.mov') || is_dir($file)) {
						$dirs[] = $file;
					}
				}
			}
			closedir($handle);
		}
		if (count($dirs)) {
                        sort($dirs);
                        foreach($dirs as $dir) {
                                echo '<a rel="one-big-group" href="',$image_dir,$dir,'">',$dir,'</a><br>',"\n";
                        }
                }
		
		/* step two: loop through, format gallery */
		if(count($files))
		{
			sort($files);
			foreach($files as $file)
			{
				$count++;
				echo '<a class="photo-link" rel="one-big-group" href="',$image_dir,substr(str_replace('.thm','',$file),1),'"><img src="',$image_dir,$file,'" width="100" /></a>';
				if($count % $per_column == 0) { echo '<div class="clear"></div>'; }
			}
		}
		else
		{
			echo '<p>There are no images in this gallery.</p>';
		}
		
	?>
	
	</div>

</body>

</html>

