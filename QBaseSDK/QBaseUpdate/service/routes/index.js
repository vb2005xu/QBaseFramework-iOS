var express = require('express');
var router = express.Router();
var fs = require('fs');

var file = 'update_config.json';

var json = 'callback_json';

fs.readFile(file, 'utf-8', function(error, data){  
        if(error) {
        	// 读取失败 
        	console.log('failed');
        } else{  
            // 读取成功  
            json = data;
        }
    });  


/* GET home page. */
router.get('/', function(req, res) {

	console.log(json);

	res.send(json);
});

module.exports = router;
