#ifndef _PROB_PARM_H_
#define _PROB_PARM_H_

#include <AMReX_REAL.H>
#include <AMReX_GpuQualifiers.H>
#include <AMReX_GpuMemory.H>

struct ProbParmDevice
{
  amrex::Real p0 = 1013250.0;
  amrex::Real p1 = 1013250.0;
  amrex::Real rho0 = 1.226e-3;
  amrex::Real rho1 = 1.226e-3;
  amrex::Real T0 = 300.0;
  amrex::Real T1 = 300.0;
  amrex::Real e0 = 1013250.0/0.4;
  amrex::Real e1 = 1013250.0/0.4;
  amrex::Real x1 = 4.2;
  amrex::GpuArray<amrex::Real, NUM_SPECIES> massfrac = {1.0};
};

struct ProbParmHost
{
  ProbParmHost() {}
};

#endif
