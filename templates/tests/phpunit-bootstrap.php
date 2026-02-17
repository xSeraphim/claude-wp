<?php
/**
 * PHPUnit bootstrap for WordPress plugin tests.
 *
 * @package CHANGE-ME
 */

$_tests_dir = getenv( 'WP_TESTS_DIR' );

if ( ! $_tests_dir ) {
	$_tests_dir = '/tmp/wordpress-tests-lib';
}

require_once $_tests_dir . '/includes/functions.php';

/**
 * Manually load the plugin under test.
 */
function change_me_manually_load_plugin() {
	require dirname( __DIR__, 2 ) . '/CHANGE-ME.php';
}

tests_add_filter( 'muplugins_loaded', 'change_me_manually_load_plugin' );

require $_tests_dir . '/includes/bootstrap.php';
