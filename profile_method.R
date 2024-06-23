opts <- ConfigOpts::readOptsBare("~/DEEBdystsTrain_2/Aizawa/estimation/LinearPast_fxd_interp_a2a9545a57c293bb33c880e8446c0987/Opts_HyperParms_Propagator_Linear.json")
obs <- DEEBtrajs::readTrajs("~/DEEBdystsTrain_2/Aizawa/observation/truth0001obs0001.csv")
parms <- createLinear(obs, opts)
prof <-
  profvis::profvis(
    predictLinear(parms, opts, startState=obs$state[1000,], len=200)
  )
