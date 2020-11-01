
! DO NOT EDIT THIS FILE!!!
!
! This file is automatically generated by write_probin.py at
! compile-time.
!
! To add a runtime parameter, do so by editting the appropriate _parameters
! file.

! This module stores the runtime parameters.  The probin_init() routine is
! used to initialize the runtime parameters

module extern_probin_module

  use amrex_fort_module, only : rt => amrex_real

  implicit none

  private

  real (kind=rt), save, public :: eos_gamma = 5.d0/3.d0
  !$acc declare create(eos_gamma)
  real (kind=rt), save, public :: small_massfrac = 1.d-30
  !$acc declare create(small_massfrac)
  real (kind=rt), save, public :: mwt_scalar = 1.0
  !$acc declare create(mwt_scalar)
  integer, save, public :: numaux = 0
  !$acc declare create(numaux)
  character (len=256), save, public :: auxnamesin = ""
  !$acc declare create(auxnamesin)
  real (kind=rt), save, public :: react_T_min = 200.d0
  !$acc declare create(react_T_min)
  real (kind=rt), save, public :: react_T_max = 5000.d0
  !$acc declare create(react_T_max)
  real (kind=rt), save, public :: react_rho_min = 1.e-10
  !$acc declare create(react_rho_min)
  real (kind=rt), save, public :: react_rho_max = 1.e10
  !$acc declare create(react_rho_max)
  integer, save, public :: new_Jacobian_each_cell = 0
  !$acc declare create(new_Jacobian_each_cell)
  real (kind=rt), save, public :: const_conductivity = 1.0d0
  !$acc declare create(const_conductivity)
  real (kind=rt), save, public :: const_viscosity = 1.0d-4
  !$acc declare create(const_viscosity)
  real (kind=rt), save, public :: const_bulk_viscosity = 0.d0
  !$acc declare create(const_bulk_viscosity)
  real (kind=rt), save, public :: const_diffusivity = 1.0d0
  !$acc declare create(const_diffusivity)
  logical, save, public :: mks_unit = .false.
  !$acc declare create(mks_unit)

end module extern_probin_module

subroutine runtime_init(name,namlen)

  use extern_probin_module

  implicit none

  integer :: namlen
  integer :: name(namlen)

  integer :: un, i, status

  integer, parameter :: maxlen = 256
  character (len=maxlen) :: probin


  namelist /extern/ eos_gamma
  namelist /extern/ small_massfrac
  namelist /extern/ mwt_scalar
  namelist /extern/ numaux
  namelist /extern/ auxnamesin
  namelist /extern/ react_T_min
  namelist /extern/ react_T_max
  namelist /extern/ react_rho_min
  namelist /extern/ react_rho_max
  namelist /extern/ new_Jacobian_each_cell
  namelist /extern/ const_conductivity
  namelist /extern/ const_viscosity
  namelist /extern/ const_bulk_viscosity
  namelist /extern/ const_diffusivity
  namelist /extern/ mks_unit

  eos_gamma = 5.d0/3.d0
  small_massfrac = 1.d-30
  mwt_scalar = 1.0
  numaux = 0
  auxnamesin = ""
  react_T_min = 200.d0
  react_T_max = 5000.d0
  react_rho_min = 1.e-10
  react_rho_max = 1.e10
  new_Jacobian_each_cell = 0
  const_conductivity = 1.0d0
  const_viscosity = 1.0d-4
  const_bulk_viscosity = 0.d0
  const_diffusivity = 1.0d0
  mks_unit = .false.


  ! create the filename
  if (namlen > maxlen) then
     print *, 'probin file name too long'
     stop
  endif

  do i = 1, namlen
     probin(i:i) = char(name(i))
  end do


  ! read in the namelist
  un = 9
  open (unit=un, file=probin(1:namlen), form='formatted', status='old')
  read (unit=un, nml=extern, iostat=status)

  if (status < 0) then
     ! the namelist does not exist, so we just go with the defaults
     continue

  else if (status > 0) then
     ! some problem in the namelist
     print *, 'ERROR: problem in the extern namelist'
     stop
  endif

  close (unit=un)

  !$acc update &
  !$acc device(eos_gamma, small_massfrac, mwt_scalar) &
  !$acc device(numaux, auxnamesin, react_T_min) &
  !$acc device(react_T_max, react_rho_min, react_rho_max) &
  !$acc device(new_Jacobian_each_cell, const_conductivity, const_viscosity) &
  !$acc device(const_bulk_viscosity, const_diffusivity, mks_unit)

end subroutine runtime_init
