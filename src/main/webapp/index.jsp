<%@ page import="java.util.Date, java.text.SimpleDateFormat, java.util.TimeZone" %>
	<html>

	<head>
		<title>Hello World!</title>
	</head>

	<body>
		<h1>Hello World!</h1>

		<p>It is now
			<% Date currentDate=new Date(); SimpleDateFormat sdf=new SimpleDateFormat("EEE MMM dd HH:mm:ss zzz yyyy");
				sdf.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata")); // Set timezone to IST
				out.print(sdf.format(currentDate)); %>
		</p>

	</body>

	</html>