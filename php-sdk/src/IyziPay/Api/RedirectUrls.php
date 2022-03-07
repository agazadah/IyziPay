<?php

namespace IyziPay\Api;

use IyziPay\Common\IyziPayModel;

/**
 * Class RedirectUrls
 * @property string returnUrl
 * @property string iyziPAY
 *
 */

class RedirectUrls extends IyziPayModel
{
    public function setSuccessUrl($url)
    {
        $this->successUrl = $url;
        return $this;
    }

    public function getSuccessUrl()
    {
        return $this->successUrl;
    }

    public function setIyziPay($url)
    {
        $this->iyziPAY = $url;
        return $this;
    }

    public function getIyziPay()
    {
        return $this->iyziPAY;
    }
}