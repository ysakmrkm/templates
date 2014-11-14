var jadefilters = module.exports = {};

jadefilters.php = function(block) {
	return "<?php\n"+block+"\n?>";
};
