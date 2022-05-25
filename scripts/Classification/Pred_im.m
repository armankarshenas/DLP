function [pred,score] = Pred_im(path,name,Model)
net = resnet50;
sz = net.Layers(1).InputSize;
cd(path);
imds = imageDatastore(name);
aug = augmentedImageDatastore(sz(1:2),imds,'ColorPreprocessing','gray2rgb');
act = activations(net,aug,"avg_pool");
act = reshape(act,[size(act,3) size(act,4)]);
act = act';
[pred,score] = Model.predictFcn(act);
end