function [aspectrum,wts] = audspec(pspectrum, sr, nfilts, fbtype, minfreq, maxfreq, sumpower, bwidth,IMFCC,uniformGain)
%[aspectrum,wts] = audspec(pspectrum, sr, nfilts, fbtype, minfreq, maxfreq, sumpower, bwidth)
%
% perform critical band analysis (see PLP)
% takes power spectrogram as input

if nargin < 2;  sr = 16000;                          end
if nargin < 3;  nfilts = ceil(hz2bark(sr/2))+1;      end
if nargin < 4;  fbtype = 'bark';  end
if nargin < 5;  minfreq = 0;    end
if nargin < 6;  maxfreq = sr/2; end
if nargin < 7;  sumpower = 1;   end
if nargin < 8;  bwidth = 1.0;   end
if nargin < 9;  IMFCC = 0;   end

[nfreqs,nframes] = size(pspectrum);

nfft = (nfreqs-1)*2;

if strcmp(fbtype, 'bark')
  wts = fft2barkmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq);
elseif strcmp(fbtype, 'mel')
  wts = fft2melmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq);
elseif strcmp(fbtype, 'htkmel')
  wts = fft2melmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq, 1, 1);
elseif strcmp(fbtype, 'fcmel')
  wts = fft2melmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq, 1, 0);
elseif strcmp(fbtype, 'line')
    wts = fft2melmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq, 0, 0,1);
elseif strcmp(fbtype, 'rect')
    wts = fft2melmx(nfft, sr, nfilts, bwidth, minfreq, maxfreq, 0, 0,1,1);
else
  disp(['fbtype ', fbtype, ' not recognized']);
  error;
end
wts = wts(:, 1:nfreqs);

if(IMFCC)
    w=wts(nfilts,:);
    for i=nfreqs:-1:1
        if(w(i)~=w(i-1))
            break;
        end
    end
    wts=[wts(:,i:-1:1),wts(:,i+1:end)];
end

if(uniformGain)
for i=1:size(wts,1)
wts(i,:)=wts(i,:)/max(wts(i,:));
end
end

% Integrate FFT bins into Mel bins, in abs or abs^2 domains:
if (sumpower)
  aspectrum = wts * pspectrum;
else
  aspectrum = (wts * sqrt(pspectrum)).^2;
end

