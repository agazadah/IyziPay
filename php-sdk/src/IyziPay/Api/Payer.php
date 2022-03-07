<?php
namespace IyziPay\Api;

use IyziPay\Common\IyziPayModel;

/**
 * Class Payer
 * @property string paymentMethod
 *
 */
class Payer extends IyziPayModel
{

    /**
     * Valid Values: ["IyziPay"]
     * method will be like IyziPay, paypal, stripe etc
     * @param  string  $method
     * @return $this
     */
    public function setPaymentMethod($method)
    {
        $this->paymentMethod = $method;
        return $this;
    }

    public function getPaymentMethod()
    {
        return $this->paymentMethod;
    }

}
