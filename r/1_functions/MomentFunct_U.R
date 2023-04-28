# Moment inequality function defined in eq (27)

MomentFunct_U <- function(A_vec, D_vec, Z_vec, J0_vec, theta, Vbar){

    # input:
    # - A_vec  : J0 x 1 dim. vector of estimated revenue differential in a market
    # - D_vec  : J0 x 1 dim. vector of product portfolio in a market.
    # - Z_vec  : J0 x 1 dim. vector of instruments in a market
    # - J0_vec : J0 x 2 dim. vector of products of coca-cola and energy-product
    # - theta  : d_theta x 1 dim. vector
    # - Vbar   : tuning parameter as in Assumption 4.2

    # output:
    # - salida : 1 x J0-dim. vector of the moment function.

    J0 <- (dim(J0_vec)[1])# number of products to evaluate one-product deviation
    S0 <- (dim(unique(J0_vec(:, 2), 'stable'))[1])# number of firms

    if (S0 != (dim(theta)[1])){
        cat('error on dimension of theta')
        keyboard
    } else {

        salida <- rep(0, J0)

        for (jj0 in 1:J0){

            jj2 <- J0_vec(jj0, 2)
            theta_jj0 <- theta(jj2)
            salida(jj0) <- ((A_vec(jj0) + theta_jj0) .* D_vec(jj0) - Vbar * (1 - D_vec(jj0))) .* Z_vec(jj0)# as in eq (27)
        }

    }

}
