## Some development notes

- Remove the `fun_type` argument from `m_hat` and just check to see if the second parameter is specified.
- Centralize checks like the `num_firms != theta.shape[0]` check in `MomentFunct_L` and `MomentFunct_U` in `g_restriction` so that they are not called so many times.
- Make `IV_matrix` optional and reorder the arguments so that it is one of the last arguments (third to last in current g_restriction).
