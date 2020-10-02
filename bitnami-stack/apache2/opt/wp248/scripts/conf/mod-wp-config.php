/**
 * WP248: Additional debug seting in case of enabled
 *        We recomend this section after /* That's all, stop editing! Happy publishing. */
          Making sure Debug set correct
*/

if ( WP_DEBUG ) {
    @error_reporting( E_ALL );
    @ini_set( 'log_errors', true );
    @ini_set( 'log_errors_max_len', '0' );

    define( 'WP_DEBUG_LOG', '/opt/bitnami/apps/wordpress/logs/wordpress-errors.log' );
    define( 'WP_DEBUG_DISPLAY', false );
    @ini_set( 'display_errors', 0 );
    define( 'CONCATENATE_SCRIPTS', false );
    define( 'SAVEQUERIES', true );
    define( 'SCRIPT_DEBUG', false );
}
