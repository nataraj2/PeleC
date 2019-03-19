  ! compute the diffusion source terms and fluxes for all the
  ! conservative equations.
  ! 
module diffterm_module

  implicit none

  private

  public :: pc_diffterm

contains

  subroutine pc_diffterm(lo,  hi,&
                         dmnlo, dmnhi,&
                         Q,   Qlo,   Qhi,&
                         Dx,  Dxlo,  Dxhi,&
                         mux, muxlo, muxhi,&
                         xix, xixlo, xixhi,&
                         lamx,lamxlo,lamxhi,&
                         tx,  txlo,  txhi,&
                         Ax,  Axlo,  Axhi,&
                         fx,  fxlo,  fxhi,&
                         Dy,  Dylo,  Dyhi,&  
                         muy, muylo, muyhi,& 
                         xiy, xiylo, xiyhi,& 
                         lamy,lamylo,lamyhi,&
                         ty,  tylo,  tyhi,&
                         Ay,  Aylo,  Ayhi,&
                         fy,  fylo,  fyhi,&
                         Dz,  Dzlo,  Dzhi,&  
                         muz, muzlo, muzhi,& 
                         xiz, xizlo, xizhi,& 
                         lamz,lamzlo,lamzhi,&
                         tz,  tzlo,  tzhi,&
                         Az,  Azlo,  Azhi,&
                         fz,  fzlo,  fzhi,&
                         V,   Vlo,   Vhi,&
                         D,   Dlo,   Dhi,&
                         deltax) bind(C, name = "pc_diffterm")

    use meth_params_module, only : NVAR, UMX, UMY, UMZ, UEDEN, UFS, QVAR, QU, QV, QW, QPRES, QTEMP, QFS, QRHO
    use eos_module !this pulls in nspec, so we need to use a unique nspec to
                   !define as a parameter for the gpu
    use prob_params_module, only : physbc_lo, physbc_hi, Inflow

    implicit none

    integer, parameter  :: nspec_2=9
    integer, intent(in) ::     lo(3),    hi(3)
    integer, intent(in) ::  dmnlo(3), dmnhi(3)
    integer, intent(in) ::    Qlo(3),   Qhi(3)

    integer, intent(in) ::   Dxlo(3),  Dxhi(3)
    integer, intent(in) ::  muxlo(3), muxhi(3)
    integer, intent(in) ::  xixlo(3), xixhi(3)
    integer, intent(in) :: lamxlo(3),lamxhi(3)
    integer, intent(in) ::   txlo(3),  txhi(3)
    integer, intent(in) ::   Axlo(3),  Axhi(3)
    integer, intent(in) ::   fxlo(3),  fxhi(3)

    integer, intent(in) ::   Dylo(3),  Dyhi(3)
    integer, intent(in) ::  muylo(3), muyhi(3)
    integer, intent(in) ::  xiylo(3), xiyhi(3)
    integer, intent(in) :: lamylo(3),lamyhi(3)
    integer, intent(in) ::   tylo(3),  tyhi(3)
    integer, intent(in) ::   Aylo(3),  Ayhi(3)
    integer, intent(in) ::   fylo(3),  fyhi(3)

    integer, intent(in) ::   Dzlo(3),  Dzhi(3)
    integer, intent(in) ::  muzlo(3), muzhi(3)
    integer, intent(in) ::  xizlo(3), xizhi(3)
    integer, intent(in) :: lamzlo(3),lamzhi(3)
    integer, intent(in) ::   tzlo(3),  tzhi(3)
    integer, intent(in) ::   Azlo(3),  Azhi(3)
    integer, intent(in) ::   fzlo(3),  fzhi(3)

    integer, intent(in) ::    Dlo(3),   Dhi(3)
    integer, intent(in) ::    Vlo(3),   Vhi(3)

    double precision, intent(in   ) ::    Q(   Qlo(1):   Qhi(1),   Qlo(2):   Qhi(2),   Qlo(3):   Qhi(3), QVAR)
    double precision, intent(in   ) ::   Dx(  Dxlo(1):  Dxhi(1),  Dxlo(2):  Dxhi(2),  Dxlo(3):  Dxhi(3), nspec_2)
    double precision, intent(in   ) ::  mux( muxlo(1): muxhi(1), muxlo(2): muxhi(2), muxlo(3): muxhi(3)  )
    double precision, intent(in   ) ::  xix( xixlo(1): xixhi(1), xixlo(2): xixhi(2), xixlo(3): xixhi(3)  )
    double precision, intent(in   ) :: lamx(lamxlo(1):lamxhi(1),lamxlo(2):lamxhi(2),lamxlo(3):lamxhi(3)  )
    double precision, intent(in   ) ::   tx(  txlo(1):  txhi(1),  txlo(2):  txhi(2),  txlo(3):  txhi(3), 6)
    double precision, intent(in   ) ::   Ax(  Axlo(1):  Axhi(1),  Axlo(2):  Axhi(2),  Axlo(3):  Axhi(3)  )
    double precision, intent(inout) ::   fx(  fxlo(1):  fxhi(1),  fxlo(2):  fxhi(2),  fxlo(3):  fxhi(3), NVAR)
    double precision, intent(in   ) ::   Dy(  Dylo(1):  Dyhi(1),  Dylo(2):  Dyhi(2),  Dylo(3):  Dyhi(3), nspec_2)
    double precision, intent(in   ) ::  muy( muylo(1): muyhi(1), muylo(2): muyhi(2), muylo(3): muyhi(3)  )
    double precision, intent(in   ) ::  xiy( xiylo(1): xiyhi(1), xiylo(2): xiyhi(2), xiylo(3): xiyhi(3)  )
    double precision, intent(in   ) :: lamy(lamylo(1):lamyhi(1),lamylo(2):lamyhi(2),lamylo(3):lamyhi(3)  )
    double precision, intent(in   ) ::   ty(  tylo(1):  tyhi(1),  tylo(2):  tyhi(2),  tylo(3):  tyhi(3), 6)
    double precision, intent(in   ) ::   Ay(  Aylo(1):  Ayhi(1),  Aylo(2):  Ayhi(2),  Aylo(3):  Ayhi(3)  )
    double precision, intent(inout) ::   fy(  fylo(1):  fyhi(1),  fylo(2):  fyhi(2),  fylo(3):  fyhi(3), NVAR)
    double precision, intent(in   ) ::   Dz(  Dzlo(1):  Dzhi(1),  Dzlo(2):  Dzhi(2),  Dzlo(3):  Dzhi(3), nspec_2)
    double precision, intent(in   ) ::  muz( muzlo(1): muzhi(1), muzlo(2): muzhi(2), muzlo(3): muzhi(3)  )
    double precision, intent(in   ) ::  xiz( xizlo(1): xizhi(1), xizlo(2): xizhi(2), xizlo(3): xizhi(3)  )
    double precision, intent(in   ) :: lamz(lamzlo(1):lamzhi(1),lamzlo(2):lamzhi(2),lamzlo(3):lamzhi(3)  )
    double precision, intent(in   ) ::   tz(  tzlo(1):  tzhi(1),  tzlo(2):  tzhi(2),  tzlo(3):  tzhi(3), 6)
    double precision, intent(in   ) ::   Az(  Azlo(1):  Azhi(1),  Azlo(2):  Azhi(2),  Azlo(3):  Azhi(3)  )
    double precision, intent(inout) ::   fz(  fzlo(1):  fzhi(1),  fzlo(2):  fzhi(2),  fzlo(3):  fzhi(3), NVAR)
    double precision, intent(inout) ::    D(   Dlo(1):   Dhi(1),   Dlo(2):   Dhi(2),   Dlo(3):   Dhi(3), NVAR)
    double precision, intent(in   ) ::    V(   Vlo(1):   Vhi(1),   Vlo(2):   Vhi(2),   Vlo(3):   Vhi(3)  )
    double precision, intent(in   ) :: deltax(3)

    integer :: i, j, k, n
    double precision :: tauxx, tauxy, tauxz, tauyx, tauyy, tauyz, tauzx, tauzy, tauzz, divu
    double precision :: Uface1, Uface2, Uface3, dudx, dvdx, dwdx, dudy, dvdy, dwdy, dudz, dvdz, dwdz
    double precision :: pface, hface, Xface, Yface
    double precision :: dTdx, dTdy, dTdz, dXdx, dXdy, dXdz, Vd
    double precision :: Vc(lo(1)-1:hi(1)+1,lo(2)-1:hi(2)+1,lo(3)-1:hi(3)+1)
    double precision :: dlnpi, gfaci(lo(1):hi(1)+1)
    double precision :: dlnpj, gfacj(lo(2):hi(2)+1)
    double precision :: dlnpk, gfack(lo(3):hi(3)+1)
    double precision :: X(lo(1)-1:hi(1)+1,lo(2)-1:hi(2)+1,lo(3)-1:hi(3)+1,1:nspec_2)
    double precision :: hii(lo(1)-1:hi(1)+1,lo(2)-1:hi(2)+1,lo(3)-1:hi(3)+1,1:nspec_2)
    double precision, parameter :: twoThirds = 2.d0/3.d0
    double precision :: dxinv(3)

    !$acc routine(eos_ytx_vec_gpu) gang
    !$acc routine(eos_hi_vec_gpu) gang

    dxinv = 1.d0/deltax

    gfaci = dxinv(1)
    if (lo(1).le.dmnlo(1) .and. physbc_lo(1).eq.Inflow) gfaci(dmnlo(1)) = gfaci(dmnlo(1)) * TWO
    if (hi(1).gt.dmnhi(1) .and. physbc_hi(1).eq.Inflow) gfaci(dmnhi(1)+1) = gfaci(dmnhi(1)+1) * TWO
    gfacj = dxinv(2)
    if (lo(2).le.dmnlo(2) .and. physbc_lo(2).eq.Inflow) gfacj(dmnlo(2)) = gfacj(dmnlo(2)) * TWO
    if (hi(2).gt.dmnhi(2) .and. physbc_hi(2).eq.Inflow) gfacj(dmnhi(2)+1) = gfacj(dmnhi(2)+1) * TWO
    gfack = dxinv(3)
    if (lo(3).le.dmnlo(3) .and. physbc_lo(3).eq.Inflow) gfack(dmnlo(3)) = gfack(dmnlo(3)) * TWO
    if (hi(3).gt.dmnhi(3) .and. physbc_hi(3).eq.Inflow) gfack(dmnhi(3)+1) = gfack(dmnhi(3)+1) * TWO

    !$acc update device(nvar,umx,umy,umz,ueden,ufs,qvar,qu,qv,qw,qpres,qtemp,qfs,qrho)
    !$acc enter data copyin(q,hi,lo,ax,ay,az,tx,ty,tz,dx,dy,dz,lamx,lamy,lamz,gfaci,gfacj,gfack,mux,muy,muz,xix,xiy,xiz,dxinv,v,hii,x,dmnlo,dmnhi,physbc_lo,physbc_hi,fx,fy,fz) create(vc,d)

    !$acc parallel present(q,x,lo,hi,hii)
    call eos_ytx_vec_gpu(q,x,lo,hi,nspec_2,qfs,qvar)
    call eos_hi_vec_gpu(q,hii,lo,hi,nspec_2,qtemp,qvar,qfs)
    !$acc end parallel

    !$acc kernels present(hi,lo,ax,ay,az,tx,ty,tz,dx,dy,dz,lamx,lamy,lamz,gfaci,gfacj,gfack,mux,muy,muz,xix,xiy,xiz,dxinv,v,hii,x,q,dmnlo,dmnhi,physbc_lo,physbc_hi,vc,fx,fy,fz,d)
    !$acc loop collapse(3) private(dtdx,dudx,dvdx,dwdx,dudy,dvdy,dudz,dwdz,tauxx,tauxy,tauxz,uface1,uface2,uface3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)+1
             dTdx = gfaci(i) * (Q(i,j,k,QTEMP) - Q(i-1,j,k,QTEMP))
             dudx = gfaci(i) * (Q(i,j,k,QU)    - Q(i-1,j,k,QU))
             dvdx = gfaci(i) * (Q(i,j,k,QV)    - Q(i-1,j,k,QV))
             dwdx = gfaci(i) * (Q(i,j,k,QW)    - Q(i-1,j,k,QW))
             dudy = tx(i,j,k,1)
             dvdy = tx(i,j,k,2)
             dudz = tx(i,j,k,4)
             dwdz = tx(i,j,k,6)
             divu = dudx + dvdy + dwdz
             tauxx = mux(i,j,k)*(2.d0*dudx-twoThirds*divu) + xix(i,j,k)*divu
             tauxy = mux(i,j,k)*(dudy+dvdx)
             tauxz = mux(i,j,k)*(dudz+dwdx)
             Uface1 = 0.5d0*(Q(i,j,k,QU) + Q(i-1,j,k,QU))
             Uface2 = 0.5d0*(Q(i,j,k,QV) + Q(i-1,j,k,QV))
             Uface3 = 0.5d0*(Q(i,j,k,QW) + Q(i-1,j,k,QW))
             fx(i,j,k,UMX)   = - tauxx
             fx(i,j,k,UMY)   = - tauxy
             fx(i,j,k,UMZ)   = - tauxz
             fx(i,j,k,UEDEN) = - tauxx*Uface1 - tauxy*Uface2 - tauxz*Uface3 - lamx(i,j,k)*dTdx
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)+1
             Vc(i,j,k) = 0.d0
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)+1
                pface = 0.5d0*(Q(i,j,k,QPRES) + Q(i-1,j,k,QPRES))
                dlnpi = gfaci(i) * (Q(i,j,k,QPRES) - Q(i-1,j,k,QPRES)) / pface
                Xface = 0.5d0*(X(i,j,k,n) + X(i-1,j,k,n))
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i-1,j,k,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n) + hii(i-1,j,k,n))
                dXdx = gfaci(i) * (X(i,j,k,n) - X(i-1,j,k,n))
                Vd = -Dx(i,j,k,n)*(dXdx + (Xface - Yface) * dlnpi)
                Vc(i,j,k) = Vc(i,j,k) + Vd
                fx(i,j,k,UFS+n-1) = Vd
                fx(i,j,k,UEDEN) = fx(i,j,k,UEDEN) + Vd*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)+1
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i-1,j,k,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n) + hii(i-1,j,k,n))
                fx(i,j,k,UFS+n-1) = fx(i,j,k,UFS+n-1) - Yface*Vc(i,j,k)
                fx(i,j,k,UEDEN)   = fx(i,j,k,UEDEN)   - Yface*Vc(i,j,k)*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)+1
             fx(i,j,k,UMX)   = fx(i,j,k,UMX)   * Ax(i,j,k)
             fx(i,j,k,UMY)   = fx(i,j,k,UMY)   * Ax(i,j,k)
             fx(i,j,k,UMZ)   = fx(i,j,k,UMZ)   * Ax(i,j,k)
             fx(i,j,k,UEDEN) = fx(i,j,k,UEDEN) * Ax(i,j,k)
          enddo
       enddo
    enddo
    !$acc loop collapse(4)
    do n=UFS,UFS+nspec_2-1
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)+1
                fx(i,j,k,n) = fx(i,j,k,n) * Ax(i,j,k)
             enddo
          enddo
       enddo
    enddo

    !$acc loop collapse(3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)+1
          do i=lo(1),hi(1)
             dTdy = gfacj(j) * (Q(i,j,k,QTEMP) - Q(i,j-1,k,QTEMP))
             dudy = gfacj(j) * (Q(i,j,k,QU)    - Q(i,j-1,k,QU))
             dvdy = gfacj(j) * (Q(i,j,k,QV)    - Q(i,j-1,k,QV))
             dwdy = gfacj(j) * (Q(i,j,k,QW)    - Q(i,j-1,k,QW))
             dudx = ty(i,j,k,1)
             dvdx = ty(i,j,k,2)
             dvdz = ty(i,j,k,5)
             dwdz = ty(i,j,k,6)
             divu = dudx + dvdy + dwdz
             tauyx = muy(i,j,k)*(dudy+dvdx)
             tauyy = muy(i,j,k)*(2.d0*dvdy-twoThirds*divu) + xiy(i,j,k)*divu
             tauyz = muy(i,j,k)*(dwdy+dvdz)
             Uface1 = 0.5d0*(Q(i,j,k,QU) + Q(i,j-1,k,QU))
             Uface2 = 0.5d0*(Q(i,j,k,QV) + Q(i,j-1,k,QV))
             Uface3 = 0.5d0*(Q(i,j,k,QW) + Q(i,j-1,k,QW))
             fy(i,j,k,UMX)   = - tauyx
             fy(i,j,k,UMY)   = - tauyy
             fy(i,j,k,UMZ)   = - tauyz
             fy(i,j,k,UEDEN) = - tauyx*Uface1 - tauyy*Uface2 - tauyz*Uface3 - lamy(i,j,k)*dTdy
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)+1
          do i=lo(1),hi(1)
             Vc(i,j,k) = 0.d0
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)+1
             do i=lo(1),hi(1)
                pface = 0.5d0*(Q(i,j,k,QPRES) + Q(i,j-1,k,QPRES))
                dlnpj = gfacj(j) * (Q(i,j,k,QPRES) - Q(i,j-1,k,QPRES)) / pface
                Xface = 0.5d0*(X(i,j,k,n) + X(i,j-1,k,n))
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i,j-1,k,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n)   + hii(i,j-1,k,n))
                dXdy = gfacj(j) * (X(i,j,k,n) - X(i,j-1,k,n))
                Vd = -Dy(i,j,k,n)*(dXdy + (Xface - Yface) * dlnpj)
                Vc(i,j,k) = Vc(i,j,k) + Vd
                fy(i,j,k,UFS+n-1) = Vd
                fy(i,j,k,UEDEN) = fy(i,j,k,UEDEN) + Vd*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)+1
             do i=lo(1),hi(1)
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i,j-1,k,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n) + hii(i,j-1,k,n))
                fy(i,j,k,UFS+n-1) = fy(i,j,k,UFS+n-1) - Yface*Vc(i,j,k)
                fy(i,j,k,UEDEN)   = fy(i,j,k,UEDEN)   - Yface*Vc(i,j,k)*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)
       do j=lo(2),hi(2)+1
          do i=lo(1),hi(1)
             fy(i,j,k,UMX)   = fy(i,j,k,UMX)   * Ay(i,j,k)
             fy(i,j,k,UMY)   = fy(i,j,k,UMY)   * Ay(i,j,k)
             fy(i,j,k,UMZ)   = fy(i,j,k,UMZ)   * Ay(i,j,k)
             fy(i,j,k,UEDEN) = fy(i,j,k,UEDEN) * Ay(i,j,k)
          enddo
       enddo
    enddo
    !$acc loop collapse(4)
    do n=UFS,UFS+nspec_2-1
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)+1
             do i=lo(1),hi(1)
                fy(i,j,k,n) = fy(i,j,k,n) * Ay(i,j,k)
             enddo
          enddo
       enddo
    enddo

    !$acc loop collapse(3)
    do k=lo(3),hi(3)+1
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)
             dTdz = gfack(k) * (Q(i,j,k,QTEMP) - Q(i,j,k-1,QTEMP))
             dudz = gfack(k) * (Q(i,j,k,QU)    - Q(i,j,k-1,QU))
             dvdz = gfack(k) * (Q(i,j,k,QV)    - Q(i,j,k-1,QV))
             dwdz = gfack(k) * (Q(i,j,k,QW)    - Q(i,j,k-1,QW))
             dudx = tz(i,j,k,1)
             dwdx = tz(i,j,k,3)
             dvdy = tz(i,j,k,5)
             dwdy = tz(i,j,k,6)
             divu = dudx + dvdy + dwdz
             tauzx = muz(i,j,k)*(dudz+dwdx)
             tauzy = muz(i,j,k)*(dvdz+dwdy)
             tauzz = muz(i,j,k)*(2.d0*dwdz-twoThirds*divu) + xiz(i,j,k)*divu
             Uface1 = 0.5d0*(Q(i,j,k,QU) + Q(i,j,k-1,QU))
             Uface2 = 0.5d0*(Q(i,j,k,QV) + Q(i,j,k-1,QV))
             Uface3 = 0.5d0*(Q(i,j,k,QW) + Q(i,j,k-1,QW))
             fz(i,j,k,UMX)   = - tauzx
             fz(i,j,k,UMY)   = - tauzy
             fz(i,j,k,UMZ)   = - tauzz
             fz(i,j,k,UEDEN) = - tauzx*Uface1 - tauzy*Uface2 - tauzz*Uface3 - lamz(i,j,k)*dTdz
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)+1
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)
             Vc(i,j,k) = 0.d0
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)+1
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)
                pface = 0.5d0*(Q(i,j,k,QPRES) + Q(i,j,k-1,QPRES))
                dlnpk = gfack(k) * (Q(i,j,k,QPRES) - Q(i,j,k-1,QPRES)) / pface
                Xface = 0.5d0*(X(i,j,k,n) + X(i,j,k-1,n))
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i,j,k-1,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n) + hii(i,j,k-1,n))
                dXdz = dxinv(3) * (X(i,j,k,n) - X(i,j,k-1,n))
                Vd = -Dz(i,j,k,n)*(dXdz + (Xface - Yface) * dlnpk)
                Vc(i,j,k) = Vc(i,j,k) + Vd
                fz(i,j,k,UFS+n-1) = Vd
                fz(i,j,k,UEDEN) = fz(i,j,k,UEDEN) + Vd*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop seq
    do n=1,nspec_2
       !$acc loop collapse(3)
       do k=lo(3),hi(3)+1
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)
                Yface = 0.5d0*(Q(i,j,k,QFS+n-1) + Q(i,j,k-1,QFS+n-1))
                hface = 0.5d0*(hii(i,j,k,n) + hii(i,j,k-1,n))
                fz(i,j,k,UFS+n-1) = fz(i,j,k,UFS+n-1) - Yface*Vc(i,j,k)
                fz(i,j,k,UEDEN)   = fz(i,j,k,UEDEN)   - Yface*Vc(i,j,k)*hface
             end do
          enddo
       enddo
    enddo
    !$acc loop collapse(3)
    do k=lo(3),hi(3)+1
       do j=lo(2),hi(2)
          do i=lo(1),hi(1)
             fz(i,j,k,UMX)   = fz(i,j,k,UMX)   * Az(i,j,k)
             fz(i,j,k,UMY)   = fz(i,j,k,UMY)   * Az(i,j,k)
             fz(i,j,k,UMZ)   = fz(i,j,k,UMZ)   * Az(i,j,k)
             fz(i,j,k,UEDEN) = fz(i,j,k,UEDEN) * Az(i,j,k)
          enddo
       enddo
    enddo
    !$acc loop collapse(4)
    do n=UFS,UFS+nspec_2-1
       do k=lo(3),hi(3)+1
          do j=lo(2),hi(2)
             do i=lo(1),hi(1)
                fz(i,j,k,n) = fz(i,j,k,n) * Az(i,j,k)
             enddo
          enddo
       enddo
    enddo

    !$acc loop collapse(4)
    do n=1,NVAR
       do k = lo(3), hi(3)
          do j = lo(2), hi(2)
             do i = lo(1), hi(1)
                D(i,j,k,n) = - (fx(i+1,j,k,n)-fx(i,j,k,n) &
                               +fy(i,j+1,k,n)-fy(i,j,k,n) &
                               +fz(i,j,k+1,n)-fz(i,j,k,n) )/V(i,j,k)
             end do
          end do
       end do
    end do
    !$acc end kernels
    !$acc exit data delete(hi,lo,ax,ay,az,tx,ty,tz,dx,dy,dz,lamx,lamy,lamz,gfaci,gfacj,gfack,mux,muy,muz,xix,xiy,xiz,dxinv,v,hii,x,q,dmnlo,dmnhi,physbc_lo,physbc_hi,vc) copyout(fx,fy,fz,d)

  end subroutine pc_diffterm

end module diffterm_module
